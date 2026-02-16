import 'package:flutter/material.dart';

/// Obscura Neo-Noir Design System
/// Color palette: Deep blacks, rich purples, atmospheric shadows
class AppColors {
  AppColors._();

  // Nested structure
  static const background = _BackgroundColors();
  static const brand = _BrandColors();
  static const text = _TextColors();
  static const status = _StatusColors();
  static const border = _BorderColors();
  static const shadow = _ShadowColors();

  // Flat const values (for const contexts)
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFFA1A1AA);
  static const textMuted = Color(0xFF52525B);
  static const brandPrimary = Color(0xFF9D4EDD);
  static const brandSecondary = Color(0xFF3C096C);
  static const brandAccent = Color(0xFFE0AAFF);
  static const brandGlow = Color(0x4D9D4EDD); // rgba(157, 78, 221, 0.3)
  static const statusSuccess = Color(0xFF34D399);
  static const statusWarning = Color(0xFFFBBF24);
  static const statusError = Color(0xFFF87171);
  static const backgroundPrimary = Color(0xFF000000);
  static const backgroundSecondary = Color(0xFF050508);
  static const backgroundTertiary = Color(0xFF0A0A0E);
  static const backgroundCard = Color(0xFF0A0A0E);
  static const backgroundGlass = Color(0xB30A0A0E); // rgba(10, 10, 14, 0.7)
  static const borderDefault = Color(0xFF1A1A24);
  static const shadowSoft = Color(0x80000000); // rgba(0, 0, 0, 0.5)
  static const shadowGlow = Color(0x269D4EDD); // rgba(157, 78, 221, 0.15)
}

class _BackgroundColors {
  const _BackgroundColors();

  final Color primary = const Color(0xFF000000); // Pure black
  final Color secondary = const Color(0xFF050508); // Very dark blue-black
  final Color tertiary = const Color(0xFF0A0A0E); // Dark card
  final Color card = const Color(0xFF0A0A0E);
  final Color glass = const Color(0xB30A0A0E); // Glass effect (70% opacity)
  final Color glassLight = const Color(0x0DFFFFFF); // Very light glass (5% white)
  final Color glassMedium = const Color(0x14FFFFFF); // Medium glass (8% white)
}

class _BrandColors {
  const _BrandColors();

  final Color primary = const Color(0xFF9D4EDD); // Deep purple (lighter)
  final Color secondary = const Color(0xFF3C096C); // Dark purple
  final Color tertiary = const Color(0xFF5A189A); // Medium purple
  final Color accent = const Color(0xFFE0AAFF); // Light lavender
  final Color dark = const Color(0xFF240046); // Very dark purple
  final Color glow = const Color(0x4D9D4EDD); // Glow effect (30% opacity)
  final Color glowSubtle = const Color(0x269D4EDD); // Subtle glow (15% opacity)
}

class _TextColors {
  const _TextColors();

  final Color primary = const Color(0xFFFAFAFA); // Off-white
  final Color secondary = const Color(0xFFA1A1AA);
  final Color muted = const Color(0xFF52525B);
  final Color accent = const Color(0xFFE0AAFF);
  final Color onBrand = const Color(0xFFFAFAFA);

  // Note: onBrandGradient removed as it can't be const
  // Use gradient text directly in widgets when needed
}

class _StatusColors {
  const _StatusColors();

  final Color success = const Color(0xFF34D399); // Muted green
  final Color successDim = const Color(0x1A34D399);
  final Color warning = const Color(0xFFFBBF24);
  final Color warningDim = const Color(0x1AFBBF24);
  final Color error = const Color(0xFFF87171);
  final Color errorDim = const Color(0x1AF87171);
  final Color info = const Color(0xFF9D4EDD);
  final Color infoDim = const Color(0x1A9D4EDD);
}

class _BorderColors {
  const _BorderColors();

  final Color default_ = const Color(0xFF1A1A24);
  final Color subtle = const Color(0xFF1E1E2E);
  final Color focus = const Color(0xFF9D4EDD);
  final Color glass = const Color(0x1AFFFFFF); // Subtle white border (10%)
  final Color glassHighlight = const Color(0x0DFFFFFF); // Very subtle (5%)
}

class _ShadowColors {
  const _ShadowColors();

  final Color soft = const Color(0x80000000); // rgba(0, 0, 0, 0.5)
  final Color medium = const Color(0x66000000); // rgba(0, 0, 0, 0.4)
  final Color glow = const Color(0x4D9D4EDD); // rgba(157, 78, 221, 0.3)
  final Color glowSubtle = const Color(0x269D4EDD); // rgba(157, 78, 221, 0.15)
  final Color innerGlow = const Color(0x1A9D4EDD); // rgba(157, 78, 221, 0.1)
}

