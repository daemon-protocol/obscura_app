# Obscura Vault Logo

This folder should contain the Obscura Vault application logo in various formats.

## Required Logo Files

### App Icon
- `icon.png` - Main app icon (1024x1024px recommended)
  - Used for: Android adaptive icon, iOS app icon

### App Logo
- `logo.png` - App logo with transparency (512x512px recommended)
  - Used for: In-app branding, headers

### Splash Screen
- `splash.png` - Splash screen logo (400x400px recommended)
  - Used for: App launch screen

### Favicon
- `favicon.png` - Web version favicon (192x192px)
  - Used for: Web version PWA

## Logo Specifications

- **Format**: PNG with transparency
- **Primary Color**: Refer to your brand guidelines
- **Background**: Ensure logo works on both light and dark backgrounds
- **Minimum Size**: 512x512px for scalability

## How to Add Logo

1. Place your logo files in this folder
2. Reference them in code using:
   ```dart
   Image.asset('assets/logo/logo.png')
   ```
3. Make sure the logo is declared in `pubspec.yaml` under the `assets` section

## Platform-Specific Icons

### Android
Place additional sizes in `android/app/src/main/res/mipmap-*` folders:
- mipmap-mdpi: 48x48px
- mipmap-hdpi: 72x72px
- mipmap-xhdpi: 96x96px
- mipmap-xxhdpi: 144x144px
- mipmap-xxxhdpi: 192x192px

### iOS
Configure in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Design Guidelines

- Keep the design simple and recognizable
- Ensure readability at small sizes
- Test on both light and dark backgrounds
- Maintain consistent padding/margins
