-- ============================================================================
-- Smart Notification System — Supabase schema, triggers & helpers
-- ============================================================================
-- Covers the three core notification flows of the app:
--   1. Lecture updates & deletions  -> push to all users with an active booking
--   2. Lecturer completion           -> push to the lecturer's device
--      ("بارك الله في علمك ونفعنا ونفعك به")
--   3. Interest-based recommendations-> push to users interested in a category
--
-- Flow model:
--   Event (INSERT/UPDATE/DELETE on content tables)
--     -> PL/pgSQL trigger enqueues a row into `public.notifications`
--     -> Supabase Database Webhook / pg_cron picks the row up
--     -> Supabase Edge Function (`send-notification`) resolves the recipient
--       device tokens from `public.user_devices` and calls the FCM HTTP v1 API
--     -> notification marked as dispatched.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Notifications outbox (written by triggers / backend, read by the app)
-- ----------------------------------------------------------------------------
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null
    check (
      type in (
        'session_update',
        'lecturer_completed',
        'recommendation',
        'booking_confirmed',
        'booking_cancelled',
        'system'
      )
    ),
  title text not null,
  body text not null,
  data jsonb not null default '{}'::jsonb,
  is_read boolean not null default false,
  dispatched boolean not null default false,
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create index if not exists idx_notifications_user_created_at
  on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;

drop policy if exists "notifications_select_own" on public.notifications;
create policy "notifications_select_own"
  on public.notifications
  for select
  using (auth.uid() = user_id);

drop policy if exists "notifications_update_own" on public.notifications;
create policy "notifications_update_own"
  on public.notifications
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- NOTE: inserts are intentionally backend-only (database triggers running as
-- the `postgres` role / Edge Functions using the service role key). End users
-- must never be able to insert rows addressed to other users.

-- ----------------------------------------------------------------------------
-- 2. User FCM device tokens
-- ----------------------------------------------------------------------------
create table if not exists public.user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  fcm_token text not null,
  platform text not null default 'android',
  device_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint uq_user_devices_user_id_fcm_token_key unique (user_id, fcm_token)
);

create index if not exists idx_user_devices_user_id
  on public.user_devices (user_id);

alter table public.user_devices enable row level security;

drop policy if exists "user_devices_select_own" on public.user_devices;
create policy "user_devices_select_own"
  on public.user_devices
  for select
  using (auth.uid() = user_id);

drop policy if exists "user_devices_insert_own" on public.user_devices;
create policy "user_devices_insert_own"
  on public.user_devices
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "user_devices_update_own" on public.user_devices;
create policy "user_devices_update_own"
  on public.user_devices
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "user_devices_delete_own" on public.user_devices;
create policy "user_devices_delete_own"
  on public.user_devices
  for delete
  using (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- 3. Helper: enqueue a notification for every user holding an active
--    booking of a session (or keep it generic for future recipient sources).
-- ----------------------------------------------------------------------------
create or replace function public.notify_active_booking_users(
  p_session_id uuid,
  p_type text,
  p_title text,
  p_body text,
  p_data jsonb
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notifications (user_id, type, title, body, data)
  select b.user_id, p_type, p_title, p_body, coalesce(p_data, '{}'::jsonb)
  from public.bookings b
  where b.session_id = p_session_id
    and b.status = 'confirmed'
    and b.cancelled_at is null;
end;
$$;

-- Helper: enqueue a recommendation for every user whose stored
-- interest (category follow) matches the published content category.
create or replace function public.notify_interested_users(
  p_content_type text,
  p_content_id uuid,
  p_category_id int,
  p_title text,
  p_body text,
  p_author_id uuid,
  p_data jsonb
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notifications (user_id, type, title, body, data)
  select cf.user_id, 'recommendation', p_title, p_body, coalesce(p_data, '{}'::jsonb)
  from public.category_follows cf
  where cf.category_id = p_content_id -- placeholder replaced below
    and cf.user_id <> p_author_id;
end;
$$;
