import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const primary = LinearGradient(
    colors: [
      AppColors.brandSecondary,
      AppColors.brandPrimary,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const secondary = LinearGradient(
    colors: [
      AppColors.brandPrimary,
      AppColors.brandAccent,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const accent = LinearGradient(
    colors: [
      AppColors.brandSecondary,
      AppColors.brandPrimary,
      AppColors.brandAccent,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const purpleToBlue = LinearGradient(
    colors: [
      Color(0xFF8B5CF6),
      Color(0xFF6366F1),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const blueToLightBlue = LinearGradient(
    colors: [
      Color(0xFF6366F1),
      Color(0xFF3B82F6),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const cardGradient = LinearGradient(
    colors: [
      Color(0x228B5CF6), // rgba(139, 92, 246, 0.2)
      Color(0x116366F1), // rgba(99, 102, 241, 0.1)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // Hybrid Mode Gradients
  // ============================================================

  /// Fast + Compressed: Blue to Purple gradient
  static const blueToPurple = LinearGradient(
    colors: [
      Color(0xFF3B82F6), // Blue
      Color(0xFF8B5CF6), // Purple
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Private + Compressed: Green to Purple gradient
  static const greenToPurple = LinearGradient(
    colors: [
      Color(0xFF10B981), // Green (statusSuccess)
      Color(0xFF8B5CF6), // Purple
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
      Color(0x1A10B981), // rgba(16, 185, 129, 0.1)
      Color(0x1A8B5CF6), // rgba(139, 92, 246, 0.1)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
