/// Asset Mapper Utility
///
/// Centralized access to all image assets in the app.
/// Provides type-safe asset path constants and helper methods.
class AppAssets {
  AppAssets._();

  // ============================================================
  // LOGO ASSETS
  // ============================================================

  /// Main logo (white background)
  static const String logoWhite = 'assets/images/logo/logo_white.png';

  /// Main logo (black background)
  static const String logoBlack = 'assets/images/logo/logo_black.png';

  /// Logo with text (white background)
  static const String logoTextWhite = 'assets/images/logo/logo_text_white.png';

  /// Logo with text (black background)
  static const String logoTextBlack = 'assets/images/logo/logo_text_black.png';

  /// OBSCURA SVG logo
  static const String logoObscuraSvg = 'assets/images/logo/OBSCURA.svg';

  /// 192x192 SVG icon
  static const String icon192Svg = 'assets/images/logo/192x192.svg';

  /// 512x512 SVG icon
  static const String icon512Svg = 'assets/images/logo/512x512.svg';

  // ============================================================
  // PARTNER LOGO ASSETS
  // ============================================================

  /// Arcium partner logo (white)
  static const String partnerArcium = 'assets/images/partners/Arcium_Isolated_White.png';

  /// Helius partner logo (white)
  static const String partnerHelius = 'assets/images/partners/Helius-Horizontal-Logo-White.png';

  /// Daemon Protocol partner logo (white)
  static const String partnerDaemon = 'assets/images/partners/daemonprotocol_logo_White_transparent_text.png';

  /// Light Protocol partner logo (white)
  static const String partnerLightProtocol = 'assets/images/partners/LogoWhiteVar1.png';

  // ============================================================
  // ICON ASSETS
  // ============================================================

  // Add icon paths here when icons are added
  // Example:
  // static const String iconTransfer = 'assets/icons/transfer.svg';
  // static const String iconSwap = 'assets/icons/swap.svg';

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get the appropriate logo based on theme brightness
  static String getLogoForTheme({bool isDark = true}) {
    return isDark ? logoWhite : logoBlack;
  }

  /// Get the appropriate text logo based on theme brightness
  static String getLogoTextForTheme({bool isDark = true}) {
    return isDark ? logoTextWhite : logoTextBlack;
  }

  /// Get all partner logo paths
  static const List<String> allPartnerLogos = [
    partnerDaemon,
    partnerArcium,
    partnerHelius,
    partnerLightProtocol,
  ];

  /// Partner logo display names
  static const Map<String, String> partnerNames = {
    partnerDaemon: 'Daemon Protocol',
    partnerArcium: 'Arcium',
    partnerHelius: 'Helius',
    partnerLightProtocol: 'Light Protocol',
  };

  /// Get partner name from logo path
  static String getPartnerName(String logoPath) {
    return partnerNames[logoPath] ?? 'Partner';
  }
}

// ============================================================
// EMOJI ICONS (fallback for action cards before SVG icons are added)
// ============================================================

/// Temporary emoji icons for action cards
/// These will be replaced with SVG icons in production
class ActionIcons {
  ActionIcons._();

  static const String transfer = '🔒';
  static const String swap = '🔄';
  static const String darkPool = '📊';
  static const String darkOtc = '💼';
  static const String portfolio = '💎';
  static const String history = '📜';
  static const String shield = '🛡️';
  static const String lock = '🔐';
  static const String unlock = '🔓';
  static const String settings = '⚙️';
}

// ============================================================
// STATUS ICONS
// ============================================================

/// Status indicators for UI elements
class StatusIcons {
  StatusIcons._();

  static const String success = '✓';
  static const String error = '✕';
  static const String warning = '⚠';
  static const String info = 'ⓘ';
  static const String loading = '⋯';
}
