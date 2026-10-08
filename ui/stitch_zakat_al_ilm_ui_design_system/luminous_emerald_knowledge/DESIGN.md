---
name: Luminous Emerald Knowledge
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#bacbbe'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#859589'
  outline-variant: '#3c4a41'
  surface-tint: '#27e199'
  primary: '#44f3a9'
  on-primary: '#003822'
  primary-container: '#00d68f'
  on-primary-container: '#005737'
  inverse-primary: '#006c46'
  secondary: '#4edea3'
  on-secondary: '#003824'
  secondary-container: '#00a572'
  on-secondary-container: '#00311f'
  tertiary: '#79edb9'
  on-tertiary: '#003825'
  tertiary-container: '#5cd09e'
  on-tertiary-container: '#00563b'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#54feb3'
  primary-fixed-dim: '#27e199'
  on-primary-fixed: '#002112'
  on-primary-fixed-variant: '#005234'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#85f8c4'
  tertiary-fixed-dim: '#68dba9'
  on-tertiary-fixed: '#002114'
  on-tertiary-fixed-variant: '#005137'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  display-lg:
    fontFamily: IBM Plex Sans
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 44px
  headline-lg:
    fontFamily: IBM Plex Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: IBM Plex Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-sm:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  label-md:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 18px
  mono-sm:
    fontFamily: Space Mono
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system expresses the spiritual and intellectual gravitas of sharing sacred, academic, and practical wisdom ("زكاة العلم"). The design fuses a contemplative nocturnal ambiance with cutting-edge digital precision—reminiscent of deep night studies illuminated by luminous energy.

The aesthetic blends **Glassmorphism**, **Modern Slate Minimalism**, and **Controlled Neon Radiance**:
- **Atmospheric Palette:** Midnight slate depths (`#0B1120`, `#0F172A`) evoke calm, reflective focus.
- **Luminous Guidance:** Vivid emerald and mint neon hues (`#00D68F`, `#10B981`) symbolize growth, knowledge transfer, and vitality, used deliberately for focal points and interactive states.
- **RTL-First Structure:** Rooted in right-to-left orientation, prioritizing seamless Arabic typographic rhythm with balanced Latin complementation.
- **Tactile Depth:** Subtle frosted backdrops, diffused outer neon halos, and crisp sub-pixel hairline borders elevate the interface beyond standard flat dark themes.

## Colors

The palette establishes an ultra-refined dark mode foundation optimized for OLED screens and extended night reading sessions.

### Semantic Mapping
- **Canvas / Background Root:** `#0B1120` (Deep obsidian slate)
- **Primary Canvas / Views:** `#0F172A` (Rich slate dark)
- **Elevated Surfaces / Cards:** `#131E31` (Midnight navy-tinted slate)
- **Interactive Tonal Surface:** `#1E293B` (Lighter structural slate for inputs, badges, and inactive buttons)
- **Border / Outline Tone:** `#334155` (Subtle boundary slate)
- **Primary Accent:** `#00D68F` (Luminous Neon Mint; high-energy interactive focus, main brand calls to action, active indicators)
- **Secondary Accent:** `#10B981` (Vibrant Emerald; secondary actions, success tags, progress completions)
- **Tertiary Accent:** `#059669` (Deep Jade; pressed states, supporting metric indicators)
- **Text & Foreground:**
  - High-Contrast Primary Text: `#F8FAFC` (Pure crisp off-white, meeting strict AAA contrast ratios)
  - Muted Secondary Label / Detail: `#94A3B8` (Soft cool slate)
  - Ghost / Disabled Copy: `#64748B` (Subdued structural grey)

## Typography

The typographical hierarchy supports fluid multi-lingual reading with seamless right-to-left (RTL) Arabic layout behavior:
- **Primary Typeface (`IBM Plex Sans` / `IBM Plex Sans Arabic`):** Neutral, crisp, highly legible across Arabic and Latin glyphs at all optical sizes. Headlines use semi-bold and bold weights to project authority.
- **Monospace Companion (`Space Mono` / `IBM Plex Mono`):** Applied selectively for numerical metrics, verse numbering, timestamps, and metadata tags to enforce architectural precision against flowing Arabic text.
- **Leading & Vertical Flow:** Given the tall vertical metrics and ascenders/descenders of Arabic typography, line-height is set 15–20% roomier than standard Western baselines to avoid diacritic clipping.

## Layout & Spacing

The layout is built for fluid mobile-first ergonomics with strict RTL alignment:
- **Screen Margins:** Fixed `20px` (`1.25rem`) horizontal margins on mobile screens, providing a stable breathing boundary.
- **Vertical Rythm:** 8pt modular grid. Dense UI chips and metadata use `space-xs` (4px) and `space-sm` (8px); cards and stacked sections leverage `space-md` (16px) and `space-lg` (24px).
- **Safe Area Insets:** The bottom viewport reserves a designated `96px` clearance zone to float the navigation dock without overlapping scrollable card content.

## Elevation & Depth

Visual hierarchy does not rely on standard heavy opaque shadows; rather, it uses surface tone stepping and ambient radiant neon illumination:

- **Level 0 (Base Canvas):** Background color `#0B1120` / `#0F172A`. Deep, static canvas.
- **Level 1 (Subtle Stack / Type 2 Card):** Surface `#1E293B`, border 1px solid `#334155`, shadow `0 4px 20px -2px rgba(0, 0, 0, 0.45)`.
- **Level 2 (Luminous Focus / Type 1 Card):** Surface `#131E31`, 1px border solid `#00D68F`, enveloped by a neon ambient glow `box-shadow: 0 0 15px rgba(0, 214, 143, 0.25), 0 8px 24px rgba(0, 0, 0, 0.5)`.
- **Level 3 (Tinted Accent / Type 3 Card):** Surface `rgba(0, 214, 143, 0.08)`, 1px border solid `#10B981`, ambient perimeter blur `box-shadow: 0 0 12px rgba(16, 185, 129, 0.2)`.
- **Level 4 (Floating Overlays & Docks):** Backdrop filter blur `16px`, background `rgba(15, 23, 42, 0.85)`, top border `1px solid rgba(255, 255, 255, 0.08)`, drop shadow `0 10px 30px rgba(0, 0, 0, 0.7)`.

## Shapes

The design uses a refined curvature profile (`roundedness: 2` base):
- **Base Cards & Containers:** Standardized at `16px` (`1rem`) border radius, preserving structured symmetry with the glowing perimeter lines.
- **Interactive Buttons & Chips:** `12px` to full pill (`9999px`) for quick-tap affordance.
- **Floating Bottom Dock & Add Dome:** Pill outer contour with a circular dome center, accentuating tactile, floating physics.

## Components

### 1. Navigation & Floating Bottom Dock
- **Architecture:** Floating dock suspended 16px above the device bottom safe area, spanning the width minus 40px (respecting the 20px screen margin).
- **Surfaces:** Dark glass backdrop (`rgba(15, 23, 42, 0.88)` with `backdrop-filter: blur(20px)`), bound by a 1px border (`#334155`).
- **Items:**
  - *Home (الرئيسية):* Icon + label, tinting to `#00D68F` when active.
  - *Center Raised Add Dome:* Elevated circular button (`56px` diameter) breaking the dock’s upper perimeter. Background solid `#00D68F`, glowing with `box-shadow: 0 0 20px rgba(0, 214, 143, 0.5)`. Icon rendered in `#0B1120`.
  - *Favorites (المفضلة):* Muted slate `#94A3B8`, shifting to glowing emerald on select.

### 2. Top Header Bar
- **Arrangement (RTL):** 
  - Far Right: Brand badge featuring calligraphy glyph with subtle `#00D68F` edge glow.
  - Center: Minimalist search pill (`#1E293B` background, placeholder in `#94A3B8`).
  - Far Left: Action cluster containing the notification bell (with unread dot in `#00D68F`) and user profile avatar encased in a 1.5px emerald ring.

### 3. Container Card Hierarchy
- **Container Type 1 (Active / Featured):** Background `#131E31`, 16px radius, 1px/2px border in `#00D68F`, with an active ambient glow (`0 0 15px rgba(0, 214, 143, 0.25)`).
- **Container Type 2 (Standard Content):** Background `#1E293B`, 16px radius, 1px subtle boundary (`#334155`), deep low drop shadow.
- **Container Type 3 (Highlight / Callout):** Background `rgba(0, 214, 143, 0.08)`, 16px radius, border solid `#10B981`, soft neon aura (`0 0 12px rgba(16, 185, 129, 0.2)`).

### 4. Buttons
- **Primary Button:** `#00D68F` fill, `#0B1120` text, bold weight, rounded-xl (12px), active neon hover glow.
- **Secondary Button:** Surface `#1E293B`, text `#F8FAFC`, border 1px solid `#334155`.
- **Ghost Action:** Transparent background, text `#00D68F`, underline or icon accent.

### 5. Form Inputs & Search
- **Input Field:** Height 48px, background `#131E31`, border 1px solid `#334155`, text `#F8FAFC`, placeholder `#64748B`.
- **Focus State:** Border shifts directly to `#00D68F`, accompanied by a subtle input halo `0 0 8px rgba(0, 214, 143, 0.3)`. RTL text direction aligned to the right by default.