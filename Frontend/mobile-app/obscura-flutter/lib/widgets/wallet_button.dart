import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../utils/asset_mapper.dart';
import 'wallet_modal.dart';
import 'animated_glow.dart';

/// Wallet Button Component - Neo-Noir Edition
///
/// Redesigned with glassmorphism effect for connected state,
/// animated connection indicator, better address truncation.
class WalletButton extends StatefulWidget {
  const WalletButton({super.key});

  @override
  State<WalletButton> createState() => _WalletButtonState();
}

class _WalletButtonState extends State<WalletButton> {
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    if (wallet.connected && wallet.address != null) {
      return _buildConnectedButton(wallet);
    }

    return _buildConnectButton();
  }

  Widget _buildConnectButton() {
    return GestureDetector(
      onTap: () => _showWalletModal(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.actionGradient,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          boxShadow: [AppShadows.glowSubtle],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wallet_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Connect',
              style: AppTextStyles.buttonSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedButton(WalletProvider wallet) {
    return GestureDetector(
      onTap: () => _showWalletModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: AppGradients.glassPurple,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: AppColors.border.glass,
            width: 1,
          ),
          boxShadow: [AppShadows.glowSubtle],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Connection status indicator with glow
            StatusGlow(
              isActive: true,
              type: StatusGlowType.active,
              size: 6,
            ),
            const SizedBox(width: 4),
            // Chain indicator (shown first on mobile to save space)
            if (wallet.chain != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brand.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  wallet.chain!.name.length > 8
                      ? '${wallet.chain!.name.substring(0, 6)}...'
                      : wallet.chain!.name,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.brandAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            // Wallet address with monospace font - truncated for mobile
            Flexible(
              child: Text(
                wallet.formatWalletAddress,
                style: AppTextStyles.monospaceSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const WalletModal(),
    );
  }
}

/// Glass wallet button for use in navigation/app bar
class WalletButtonGlass extends StatelessWidget {
  final bool showBalance;
  final VoidCallback? onTap;

  const WalletButtonGlass({
    super.key,
    this.showBalance = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    if (!wallet.connected || wallet.address == null) {
      return _buildConnectState();
    }

    return _buildConnectedState(wallet);
  }

  Widget _buildConnectState() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: AppGradients.glassGradient,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: AppColors.border.glass,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wallet_outlined,
              size: 16,
              color: AppColors.brandAccent,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Connect',
              style: AppTextStyles.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedState(WalletProvider wallet) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: AppGradients.glassPurple,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: AppColors.border.glass,
            width: 1,
          ),
        boxShadow: [AppShadows.glowSubtle],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status indicator
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.statusSuccess,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.statusSuccess.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Address or balance - with Flexible to prevent overflow
            Flexible(
              child: showBalance && wallet.balance != null
                  ? Text(
                      wallet.balance!,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      wallet.formatWalletAddress,
                      style: AppTextStyles.monospaceSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal wallet connection pill
class WalletPill extends StatelessWidget {
  final VoidCallback? onTap;

  const WalletPill({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return GestureDetector(
      onTap: onTap ?? () => _showWalletModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: wallet.connected
              ? AppGradients.glassPurple
              : AppGradients.actionGradient,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: wallet.connected
                ? AppColors.border.glass
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: wallet.connected ? [AppShadows.sm] : [AppShadows.glowSubtle],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (wallet.connected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.statusSuccess,
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              const Icon(
                Icons.wallet_outlined,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ],
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                wallet.connected
                    ? wallet.formatWalletAddress
                    : 'Connect',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const WalletModal(),
    );
  }
}
