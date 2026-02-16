import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Neo-Noir Typography System
///
/// Font Families:
/// - Playfair Display: Elegant serif for headlines (luxurious feel)
/// - Outfit: Modern sans-serif for subheadlines (pairs well with serif)
/// - DM Sans: Clean sans-serif for body text (readable, contemporary)
/// - Space Mono: Monospace for addresses/technical data (crypto-appropriate)
class AppTextStyles {
  AppTextStyles._();

  // ============================================================
  // FONT FAMILIES (using Google Fonts)
  // ============================================================

  static const String fontFamilyDisplay = 'PlayfairDisplay';
  static const String fontFamilySubheadline = 'Outfit';
  static const String fontFamilyBody = 'DMSans';
  static const String fontFamilyMono = 'SpaceMono';

  // ============================================================
  // HEADLINES - Serif (Playfair Display)
  // ============================================================

  static final h1 = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static final h2 = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static final h3 = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 30 / 22,
    color: AppColors.textPrimary,
  );

  static final h4 = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.textPrimary,
  );

  // ============================================================
  // SUBHEADLINES - Modern Sans (Outfit)
  // ============================================================

  static final subtitleLarge = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static final subtitle = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
    color: AppColors.textPrimary,
  );

  static final subtitleSmall = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.textSecondary,
  );

  // ============================================================
  // BODY - Clean Sans (DM Sans)
  // ============================================================

  static final body = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );

  static final bodyMedium = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 22 / 15,
    color: AppColors.textPrimary,
  );

  static final bodySmall = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textSecondary,
  );

  // ============================================================
  // LABELS
  // ============================================================

  static final label = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static final labelSmall = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static final caption = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: AppColors.textMuted,
  );

  static final captionSmall = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    color: AppColors.textMuted,
  );

  // ============================================================
  // BUTTONS
  // ============================================================

  static final button = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static final buttonSmall = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  // ============================================================
  // MONOSPACE - Technical (Space Mono)
  // ============================================================

  static final monospace = GoogleFonts.spaceMono(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  static final monospaceSmall = GoogleFonts.spaceMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textSecondary,
  );

  // ============================================================
  // SPECIAL STYLES
  // ============================================================

  /// Hero text with gradient effect
  static final hero = GoogleFonts.playfairDisplay(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    height: 52 / 42,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );

  /// Overline text (for cards, buttons)
  static final overline = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: AppColors.brandAccent,
    letterSpacing: 1.5,
  );

  /// Price/Amount display (larger, bolder)
  static final amount = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static final amountLarge = GoogleFonts.outfit(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 56 / 48,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );

  // ============================================================
  // CONST VERSIONS (for const contexts where GoogleFonts can't be used)
  // ============================================================

  static const h1Const = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    fontFamily: fontFamilyDisplay,
  );

  static const h2Const = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    fontFamily: fontFamilyDisplay,
  );

  static const h3Const = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 30 / 22,
    color: AppColors.textPrimary,
    fontFamily: fontFamilyDisplay,
  );

  static const bodyConst = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.textPrimary,
    fontFamily: fontFamilyBody,
  );

  static const labelConst = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    fontFamily: fontFamilyBody,
  );

  static const buttonConst = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: AppColors.textPrimary,
    fontFamily: fontFamilySubheadline,
  );

  static const monospaceConst = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textPrimary,
    fontFamily: fontFamilyMono,
  );
}

