# Obscura Vault Assets

This directory contains all static assets used by the Obscura Vault Flutter application.

## Directory Structure

```
assets/
├── icons/       # UI icons (navigation, status, network logos)
├── images/      # Images and illustrations
├── logo/        # App logos and branding
└── fonts/       # Custom fonts (optional, currently commented out)
```

## Current Status

All asset folders are currently **empty**. Before building for production, add the required assets.

## Quick Start

1. Add your assets to the appropriate subfolder
2. Run `flutter pub get` to ensure dependencies are installed
3. Run `flutter run` to test the app with your assets

## Asset Declaration in pubspec.yaml

Assets are declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/icons/
    - assets/images/
    - assets/logo/
```

## Asset Guidelines

- Use optimized images to reduce app size
- Provide multiple resolutions for different screen densities
- Test on both light and dark themes
- Use WebP format for better compression when possible

## Need Assets?

For placeholder assets during development, consider:
- [Flutter Icons](https://api.flutter.dev/flutter/material/Icons-class.html) - Built-in Material icons
- [Font Awesome](https://fontawesome.com/) - Popular icon set
- [Heroicons](https://heroicons.com/) - Beautiful hand-crafted icons

## Asset References

See individual README files in each subfolder:
- [icons/README.md](icons/README.md) - Icon requirements
- [images/README.md](images/README.md) - Image requirements
- [logo/README.md](logo/README.md) - Logo requirements
