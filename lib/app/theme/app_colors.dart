import 'package:flutter/material.dart';

/// Application color palette — Stitch Design System: "Luminous Emerald Knowledge".
/// Dark-first OLED-optimized theme with neon emerald accents.
class AppColors {
  AppColors._();

  // ── Canvas / Background Root ─────────────────────────────
  static const Color background = Color(0xFF0B1120); // Deep obsidian slate

  // ── Surfaces (Elevation Levels) ──────────────────────────
  static const Color surface = Color(0xFF0F172A); // Rich slate dark
  static const Color surfaceContainer = Color(0xFF171F33); // Primary canvas / views
  static const Color surfaceContainerLow = Color(0xFF131B2E); // Elevated surfaces / cards
  static const Color surfaceContainerHigh = Color(0xFF222A3D); // Interactive tonal surface
  static const Color surfaceContainerHighest = Color(0xFF2D3449); // Inputs, badges, inactive
  static const Color surfaceContainerLowest = Color(0xFF060E20); // Deepest background

  // ── Brand / Accent ────────────────────────────────────────
  static const Color primary = Color(0xFF00D68F); // Luminous Neon Mint
  static const Color onPrimary = Color(0xFF003822);
  static const Color primaryContainer = Color(0xFF00D68F);
  static const Color onPrimaryContainer = Color(0xFF005737);

  static const Color secondary = Color(0xFF10B981); // Vibrant Emerald
  static const Color onSecondary = Color(0xFF003824);
  static const Color secondaryContainer = Color(0xFF00A572);
  static const Color onSecondaryContainer = Color(0xFF00311F);

  static const Color tertiary = Color(0xFF059669); // Deep Jade
  static const Color onTertiary = Color(0xFF003825);
  static const Color tertiaryContainer = Color(0xFF5CD09E);
  static const Color onTertiaryContainer = Color(0xFF00563B);

  // ── Text & Foreground ─────────────────────────────────────
  static const Color onSurface = Color(0xFFF8FAFC); // Pure crisp off-white (AAA)
  static const Color onSurfaceVariant = Color(0xFF94A3B8); // Soft cool slate
  static const Color outline = Color(0xFF334155); // Subtle boundary slate
  static const Color outlineVariant = Color(0xFF3C4A41);

  // ── Semantic ──────────────────────────────────────────────
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF00D68F);
  static const Color onSuccess = Color(0xFF003822);
  static const Color successContainer = Color(0xFF00A572);
  static const Color onSuccessContainer = Color(0xFF00311F);

  // ── Glow / Shadow ─────────────────────────────────────────
  static const Color glowPrimary = Color(0xFF00D68F);
  static const Color glowSecondary = Color(0xFF10B981);
  static const Color glowTertiary = Color(0xFF059669);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D68F), Color(0xFF00A572)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B1120), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF131E31), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Map Grid Pattern ──────────────────────────────────────
  static const Color mapGridLine = Color(0x1400D68F);
  static const Color mapBackgroundColor = Color(0xFF17273D);

  // ── Backward-compatible aliases (for login/register views) ─
  static const Color surfaceVariant = surfaceContainerHighest;
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color onDarkSurface = Color(0xFFF1F5F9);
  static const Color onDarkSurfaceVariant = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF475569);
  static const Color darkOutlineVariant = Color(0xFF334155);
  static const Color primaryLight = Color(0xFF00D68F);
  static const Color primaryDark = Color(0xFF0B392B);
  static const Color secondaryDark = Color(0xFF00B77A);
}
