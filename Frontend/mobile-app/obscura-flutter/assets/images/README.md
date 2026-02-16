# Obscura Vault Images

This folder should contain images and illustrations used throughout the app.

## Recommended Images

### Onboarding/Illustrations
- `welcome.png` - Welcome screen illustration
- `security.png` - Security/Privacy illustration
- `wallet_created.png` - Wallet creation success illustration

### Background Images
- `background.png` - App background pattern/image
- `card_background.png` - Card backgrounds

### Token Images
- `sol.png` - Solana token icon
- `usdc.png` - USDC token icon
- `usdt.png` - USDT token icon
- `ray.png` - Raydium token icon

## Image Specifications

- **Format**: PNG or JPG (for photos)
- **Recommended Sizes**:
  - Background images: 1080x1920px (full screen)
  - Illustrations: 500x500px (square)
  - Token icons: 128x128px

## How to Add Images

1. Place your image files in this folder
2. Reference them in code using:
   ```dart
   Image.asset('assets/images/your_image.png')
   ```
3. Make sure the image is declared in `pubspec.yaml` under the `assets` section

## Optimization Tips

- Compress images to reduce app size
- Use WebP format for better compression
- Provide multiple resolutions for different screen densities (1x, 2x, 3x)
