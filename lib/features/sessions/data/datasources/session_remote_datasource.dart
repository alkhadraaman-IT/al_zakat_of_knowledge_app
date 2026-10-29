import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:al_zakat_of_knowledge_app/core/utils/supabase_timeout.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/session_entity.dart';

/// مصدر بيانات الجلسات من Supabase.
abstract class SessionRemoteDataSource {
  Future<List<BookingEntity>> getUserBookings(String userId);

  Future<List<SessionEntity>> getSessions();

  Future<List<SessionEntity>> getSessionsByPublisher(String publisherId);

  Future<SessionEntity> createSession({
    required String publisherId,
    required String title,
    required String description,
    required int categoryId,
    required String city,
    required String placeName,
    required String startsAt,
    required int durationMinutes,
    required int maxSeats,
    required double lat,
    required double lng,
  });

  Future<SessionEntity> updateSession({
    required String sessionId,
    required String title,
    required String description,
    required int categoryId,
    required String city,
    required String placeName,
    required String startsAt,
    required int durationMinutes,
    required int maxSeats,
    required double lat,
    required double lng,
  });

  Future<void> bookSession({required String sessionId});

  Future<void> cancelBooking({required String sessionId});
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final SupabaseClient supabaseClient;

  SessionRemoteDataSourceImpl({required this.supabaseClient});

  /// نستخدم profiles!publisher_id لتجنّب خطأ "more than one relationship".
  static const String _sessionWithPublisher = '*, profiles!publisher_id(name)';

  List<Map<String, dynamic>> _asRows(dynamic data) {
    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ── قراءة ─────────────────────────────────────────────
  @override
  Future<List<SessionEntity>> getSessions() async {
    final data = await supabaseClient
        .from('sessions')
        .select(_sessionWithPublisher)
        .eq('status', 'active')
        .gt('starts_at', DateTime.now().toUtc().toIso8601String())
        .order('starts_at', ascending: true);

    return _asRows(data).map(SessionEntity.fromSupabase).toList();
  }

  @override
  Future<List<SessionEntity>> getSessionsByPublisher(
    String publisherId,
  ) async {
    final data = await supabaseClient
        .from('sessions')
        .select(_sessionWithPublisher)
        .eq('publisher_id', publisherId)
        .order('created_at', ascending: false);

    return _asRows(data).map(SessionEntity.fromSupabase).toList();
  }

  @override
  Future<List<BookingEntity>> getUserBookings(String userId) async {
    final bookingRows = _asRows(
      await supabaseClient
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .eq('status', 'confirmed')
          .order('booked_at', ascending: false),
    );
    if (bookingRows.isEmpty) return [];

    final sessionIds = bookingRows
        .map((b) => b['session_id'].toString())
        .toList();
    final sessionRows = _asRows(
      await supabaseClient
          .from('sessions')
          .select(_sessionWithPublisher)
          .inFilter('id', sessionIds),
    );
    final sessionsById = {for (final r in sessionRows) r['id'].toString(): r};

    final result = <BookingEntity>[];
    for (final b in bookingRows) {
      final sessionMap = sessionsById[b['session_id'].toString()];
      if (sessionMap == null) continue;
      result.add(
        BookingEntity(
          id: b['id']?.toString() ?? '',
          sessionId: b['session_id']?.toString() ?? '',
          userId: b['user_id']?.toString() ?? '',
          status: b['status']?.toString() ?? '',
          bookedAt: b['booked_at']?.toString() ?? '',
          cancelledAt: b['cancelled_at']?.toString(),
          session: SessionEntity.fromSupabase(sessionMap),
        ),
      );
    }
    return result;
  }

  // ── كتابة ─────────────────────────────────────────────
  @override
  Future<SessionEntity> createSession({
    required String publisherId,
    required String title,
    required String description,
    required int categoryId,
    required String city,
    required String placeName,
    required String startsAt,
    required int durationMinutes,
    required int maxSeats,
    required double lat,
    required double lng,
  }) async {
    if (publisherId.isEmpty) {
      throw Exception('Publisher ID cannot be empty');
    }

    final session = SessionEntity(
      id: '',
      publisherId: publisherId,
      title: title,
      description: description,
      categoryId: categoryId,
      city: city,
      placeName: placeName,
      startsAt: startsAt,
      durationMinutes: durationMinutes,
      maxSeats: maxSeats,
      bookedCount: 0,
      status: 'active',
      lecturerName: '',
      lat: lat,
      lng: lng,
    );

    final payload = session.toInsertJson();

    final response = await supabaseClient
        .from('sessions')
        .insert(payload)
        .select(_sessionWithPublisher)
        .maybeSingleWithTimeout(operationName: 'createSession');

    if (response == null) {
      throw Exception('Session creation returned no row');
    }

    return SessionEntity.fromSupabase(response);
  }

  @override
  Future<SessionEntity> updateSession({
    required String sessionId,
    required String title,
    required String description,
    required int categoryId,
    required String city,
    required String placeName,
    required String startsAt,
    required int durationMinutes,
    required int maxSeats,
    required double lat,
    required double lng,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'category_id': categoryId,
      'city': city,
      'place_name': placeName,
      'starts_at': startsAt,
      'duration_minutes': durationMinutes,
      'max_seats': maxSeats,
      'lat': lat,
      'lng': lng,
    };

    final response = await supabaseClient
        .from('sessions')
        .update(payload)
        .eq('id', sessionId)
        .select(_sessionWithPublisher)
        .maybeSingleWithTimeout(operationName: 'updateSession');

    if (response == null) {
      throw Exception('Session update returned no row');
    }

    return SessionEntity.fromSupabase(response);
  }

  @override
  Future<void> bookSession({required String sessionId}) async {
    await supabaseClient.rpc(
      'book_session',
      params: {'p_session_id': sessionId},
    );
  }

  @override
  Future<void> cancelBooking({required String sessionId}) async {
    await supabaseClient.rpc(
      'cancel_booking',
      params: {'p_session_id': sessionId},
    );
  }
}