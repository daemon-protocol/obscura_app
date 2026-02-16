import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Neo-Noir Shadow System
///
/// Provides atmospheric shadows and glow effects for the neo-noir aesthetic.
/// Includes soft shadows for depth, glow effects with purple brand color,
/// and inner glow for glassmorphism effects.
class AppShadows {
  AppShadows._();

  // ============================================================
  // SOFT SHADOWS (for elevation and depth)
  // ============================================================

  /// Small shadow for subtle elevation
  static const sm = BoxShadow(
    color: AppColors.shadowSoft,
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );

  /// Medium shadow for cards and buttons
  static const md = BoxShadow(
    color: AppColors.shadowSoft,
    offset: Offset(0, 4),
    blurRadius: 12,
    spreadRadius: -2,
  );

  /// Large shadow for floating elements
  static const lg = BoxShadow(
    color: AppColors.shadowSoft,
    offset: Offset(0, 8),
    blurRadius: 24,
    spreadRadius: -4,
  );

  /// Extra large shadow for modals and dialogs
  static const xl = BoxShadow(
    color: AppColors.shadowSoft,
    offset: Offset(0, 16),
    blurRadius: 40,
    spreadRadius: -8,
  );

  // ============================================================
  // GLOW EFFECTS (purple brand color)
  // ============================================================

  /// Subtle glow for interactive elements
  static const glowSubtle = BoxShadow(
    color: AppColors.shadowGlow,
    offset: Offset(0, 0),
    blurRadius: 16,
    spreadRadius: 0,
  );

  /// Medium glow for focus states
  static const glow = BoxShadow(
    color: AppColors.brandGlow,
    offset: Offset(0, 0),
    blurRadius: 24,
    spreadRadius: 0,
  );

  /// Strong glow for call-to-action elements
  static const glowStrong = [
    BoxShadow(
      color: AppColors.brandGlow,
      offset: Offset(0, 0),
      blurRadius: 20,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: AppColors.shadowGlow,
      offset: Offset(0, 4),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  /// Intense glow effect (multi-layered)
  static const glowIntense = [
    BoxShadow(
      color: AppColors.brandGlow,
      offset: Offset(0, 0),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowGlow,
      offset: Offset(0, 4),
      blurRadius: 32,
      spreadRadius: 4,
    ),
    BoxShadow(
      color: Color(0x1A9D4EDD), // rgba(157, 78, 221, 0.1)
      offset: Offset(0, 8),
      blurRadius: 48,
      spreadRadius: -8,
    ),
  ];

  // ============================================================
  // INNER SHADOWS (for glassmorphism depth)
  // ============================================================

  /// Note: Flutter BoxShadow doesn't support inset shadows natively.
  /// Use InnerShadow widget or Container with custom paint for true inner shadows.
  /// This is a placeholder that can be used with InnerShadow decorator.

  static const innerGlow = BoxShadow(
    color: Color(0x1A9D4EDD), // rgba(157, 78, 221, 0.1)
    offset: Offset(0, 0),
    blurRadius: 16,
    spreadRadius: 0,
  );

  static const innerSoft = BoxShadow(
    color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
    offset: Offset(0, 1),
    blurRadius: 4,
    spreadRadius: 0,
  );

  // ============================================================
  // COMBINATION SHADOWS (shadow + glow)
  // ============================================================

  /// Soft shadow with subtle glow (for elevated cards)
  static const elevatedWithGlow = [
    BoxShadow(
      color: AppColors.shadowSoft,
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: AppColors.shadowGlow,
      offset: Offset(0, 0),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Glass card shadow (soft + inner glow effect hint)
  static const glass = [
    BoxShadow(
      color: Color(0x80000000), // shadowSoft
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x1A9D4EDD), // shadow innerGlow
      offset: Offset(0, 1),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // ============================================================
  // STATUS-BASED SHADOWS
  // ============================================================

  /// Success glow
  static const successGlow = BoxShadow(
    color: Color(0x4D34D399), // rgba(52, 211, 153, 0.3)
    offset: Offset(0, 0),
    blurRadius: 16,
    spreadRadius: 0,
  );

  /// Error glow
  static const errorGlow = BoxShadow(
    color: Color(0x4DF87171), // rgba(248, 113, 113, 0.3)
    offset: Offset(0, 0),
    blurRadius: 16,
    spreadRadius: 0,
  );

  /// Warning glow
  static const warningGlow = BoxShadow(
    color: Color(0x4DFBBF24), // rgba(251, 191, 36, 0.3)
    offset: Offset(0, 0),
    blurRadius: 16,
    spreadRadius: 0,
  );

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Create a custom glow shadow with specific color and blur
  static BoxShadow customGlow({
    required Color color,
    double blur = 16,
    double spread = 0,
    Offset offset = Offset.zero,
  }) {
    return BoxShadow(
      color: color,
      offset: offset,
      blurRadius: blur,
      spreadRadius: spread,
    );
  }

  /// Create a custom elevation shadow
  static BoxShadow customElevation({
    double blur = 12,
    double spread = -2,
    Offset offset = const Offset(0, 4),
    Color color = AppColors.shadowSoft,
  }) {
    return BoxShadow(
      color: color,
      offset: offset,
      blurRadius: blur,
      spreadRadius: spread,
    );
  }
}
