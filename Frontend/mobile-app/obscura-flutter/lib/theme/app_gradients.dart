import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Neo-Noir Gradient Collection
///
/// Provides rich gradients for the neo-noir aesthetic including:
/// - Primary brand gradients (purple tones)
/// - Glass gradients for glassmorphism effects
/// - Glow gradients for atmospheric effects
/// - Action gradients for buttons and interactive elements
class AppGradients {
  AppGradients._();

  // ============================================================
  // PRIMARY BRAND GRADIENTS (Neo-Noir Purple)
  // ============================================================

  /// Primary neo-noir gradient: deep purple to lavender
  static const noirPrimary = LinearGradient(
    colors: [
      Color(0xFF3C096C), // brandSecondary
      Color(0xFF5A189A), // brand tertiary
      Color(0xFF9D4EDD), // brandPrimary
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Dark to light purple gradient
  static const primary = LinearGradient(
    colors: [
      Color(0xFF3C096C), // brandSecondary
      Color(0xFF9D4EDD), // brandPrimary
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Light purple to lavender gradient
  static const secondary = LinearGradient(
    colors: [
      Color(0xFF9D4EDD), // brandPrimary
      Color(0xFFE0AAFF), // brandAccent
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Full purple spectrum gradient
  static const accent = LinearGradient(
    colors: [
      Color(0xFF3C096C), // brandSecondary
      Color(0xFF5A189A), // brand tertiary
      Color(0xFF9D4EDD), // brandPrimary
      Color(0xFFE0AAFF), // brandAccent
    ],
    stops: [0.0, 0.33, 0.66, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ============================================================
  // GLASS GRADIENTS (for glassmorphism effects)
  // ============================================================

  /// Subtle glass gradient for backgrounds
  static const glassGradient = LinearGradient(
    colors: [
      Color(0x0DFFFFFF), // rgba(255, 255, 255, 0.05)
      Color(0x05FFFFFF), // rgba(255, 255, 255, 0.02)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Medium glass gradient with purple tint
  static const glassPurple = LinearGradient(
    colors: [
      Color(0x149D4EDD), // rgba(157, 78, 221, 0.08)
      Color(0x089D4EDD), // rgba(157, 78, 221, 0.03)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass card gradient (subtle purple overlay)
  static const cardGradient = LinearGradient(
    colors: [
      Color(0x149D4EDD), // rgba(157, 78, 221, 0.08)
      Color(0x083C096C), // rgba(60, 9, 108, 0.03)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Top-highlight glass gradient
  static const glassTopHighlight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x14FFFFFF), // rgba(255, 255, 255, 0.08)
      Color(0x00FFFFFF), // transparent
    ],
    stops: [0.0, 1.0],
  );

  // ============================================================
  // GLOW GRADIENTS (for atmospheric effects)
  // ============================================================

  /// Radial glow gradient (for background glows)
  static final glowGradient = RadialGradient(
    colors: [
      AppColors.brandGlow, // rgba(157, 78, 221, 0.3)
      Color(0x00000000), // transparent
    ],
    stops: [0.0, 1.0],
    radius: 0.8,
    tileMode: TileMode.clamp,
  );

  /// Subtle radial glow
  static final glowGradientSubtle = RadialGradient(
    colors: [
      AppColors.shadowGlow, // rgba(157, 78, 221, 0.15)
      Color(0x00000000), // transparent
    ],
    stops: [0.0, 1.0],
    radius: 0.6,
    tileMode: TileMode.clamp,
  );

  /// Linear glow gradient for edges
  static const edgeGlow = LinearGradient(
    colors: [
      Color(0x009D4EDD), // transparent
      Color(0x269D4EDD), // rgba(157, 78, 221, 0.15)
      Color(0x009D4EDD), // transparent
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ============================================================
  // ACTION GRADIENTS (for buttons and interactive elements)
  // ============================================================

  /// Primary action gradient (button backgrounds)
  static const actionGradient = LinearGradient(
    colors: [
      Color(0xFF5A189A), // brand tertiary
      Color(0xFF9D4EDD), // brandPrimary
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Action gradient with glow (for primary CTA)
  static const actionGradientGlow = LinearGradient(
    colors: [
      Color(0xFF3C096C), // brand secondary
      Color(0xFF5A189A), // brand tertiary
      Color(0xFF9D4EDD), // brandPrimary
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Subtle action gradient (for secondary buttons)
  static const actionGradientSubtle = LinearGradient(
    colors: [
      Color(0x1A9D4EDD), // rgba(157, 78, 221, 0.1)
      Color(0x0D9D4EDD), // rgba(157, 78, 221, 0.05)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // LEGACY/COMPATIBILITY GRADIENTS
  // ============================================================

  /// Purple to blue gradient (for compatibility with existing UI)
  static const purpleToBlue = LinearGradient(
    colors: [
      Color(0xFF7B2CBF), // Purple
      Color(0xFF6366F1), // Indigo
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ============================================================
  // STATUS GRADIENTS
  // ============================================================

  /// Success gradient (green tones)
  static const success = LinearGradient(
    colors: [
      Color(0xFF34D399),
      Color(0xFF10B981),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Error gradient (red tones)
  static const error = LinearGradient(
    colors: [
      Color(0xFFF87171),
      Color(0xFFEF4444),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Warning gradient (yellow/amber tones)
  static const warning = LinearGradient(
    colors: [
      Color(0xFFFBBF24),
      Color(0xFFF59E0B),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ============================================================
  // DARK POOL & OTC GRADIENTS
  // ============================================================

  /// Dark Pool gradient (purple to pink)
  static const darkPool = LinearGradient(
    colors: [
      Color(0xFF8B5CF6), // Purple
      Color(0xFFC026D3), // Pink
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Dark OTC gradient (pink to amber)
  static const darkOtc = LinearGradient(
    colors: [
      Color(0xFFEC4899), // Pink
      Color(0xFFF59E0B), // Amber
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ============================================================
  // COMPATIBILITY GRADIENTS (for existing widgets)
  // ============================================================

  /// Fast + Compressed mode gradient (blue to purple)
  static const fastCompressed = LinearGradient(
    colors: [
      Color(0xFF3B82F6), // Blue
      Color(0xFF8B5CF6), // Purple
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Private + Compressed mode gradient (green to purple)
  static const privateCompressed = LinearGradient(
    colors: [
      Color(0xFF34D399), // Green
      Color(0xFF8B5CF6), // Purple
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Blue to Purple gradient (alias for fastCompressed)
  static const blueToPurple = fastCompressed;

  /// Green to Purple gradient (alias for privateCompressed)
  static const greenToPurple = privateCompressed;

  /// Blue to light blue gradient (for compatibility)
  static const blueToLightBlue = LinearGradient(
    colors: [
      Color(0xFF6366F1), // Indigo
      Color(0xFF3B82F6), // Blue
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Fast Compressed badge gradient (subtle)
  static const fastCompressedBadge = LinearGradient(
    colors: [
      Color(0x1A3B82F6), // rgba(59, 130, 246, 0.1)
      Color(0x1A8B5CF6), // rgba(139, 92, 246, 0.1)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Private Compressed badge gradient (subtle)
  static const privateCompressedBadge = LinearGradient(
    colors: [
      Color(0x1A34D399), // rgba(16, 185, 129, 0.1)
      Color(0x1A8B5CF6), // rgba(139, 92, 246, 0.1)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Create a custom linear gradient
  static LinearGradient customLinear({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
      stops: stops,
      tileMode: tileMode,
    );
  }

  /// Create a custom radial gradient
  static RadialGradient customRadial({
    required List<Color> colors,
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
  }) {
    return RadialGradient(
      colors: colors,
      center: center,
      radius: radius,
      stops: stops,
      tileMode: tileMode,
    );
  }
}
