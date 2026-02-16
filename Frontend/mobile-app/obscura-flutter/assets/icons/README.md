# Obscura Vault Icons

This folder should contain application icons used throughout the UI.

## Recommended Icons

### Navigation Icons
- `home.png` - Home screen icon
- `transfer.png` - Transfer/Send icon
- `swap.png` - Swap/Exchange icon
- `settings.png` - Settings icon
- `wallet.png` - Wallet icon

### Status Icons
- `success.png` - Success checkmark
- `error.png` - Error warning
- `pending.png` - Pending/loading indicator
- `connected.png` - Connected status
- `disconnected.png` - Disconnected status

### Network Icons
- `solana.png` - Solana network logo
- `ethereum.png` - Ethereum network logo
- `bsc.png` - Binance Smart Chain logo

## Icon Specifications

- **Format**: PNG with transparency (preferred) or SVG
- **Sizes**:
  - 24x24px for small icons
  - 48x48px for medium icons
  - 96x96px for large icons

## How to Add Icons

1. Place your icon files in this folder
2. Reference them in code using:
   ```dart
   Image.asset('assets/icons/your_icon.png')
   ```
3. Make sure the icon is declared in `pubspec.yaml` under the `assets` section

## Design Guidelines

- Use consistent visual style across all icons
- Ensure good contrast for both light and dark themes
- Use vector graphics (SVG) when possible for better scalability
