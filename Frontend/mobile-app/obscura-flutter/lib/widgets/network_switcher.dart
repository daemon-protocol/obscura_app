import 'package:flutter/material.dart';
import '../models/magic_block_models.dart';
import '../theme/theme.dart';

/// Network Switcher Widget
///
/// Toggle between devnet and mainnet for MagicBlock operations.
class NetworkSwitcher extends StatelessWidget {
  final MagicBlockNetwork network;
  final ValueChanged<MagicBlockNetwork> onChanged;
  final bool enabled;
  final bool showLabels;

  const NetworkSwitcher({
    super.key,
    required this.network,
    required this.onChanged,
    this.enabled = true,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: MagicBlockNetwork.values.map((n) {
          final isSelected = network == n;
          return _buildNetworkButton(n, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildNetworkButton(MagicBlockNetwork network, bool isSelected) {
    final color = network == MagicBlockNetwork.devnet
        ? AppColors.statusWarning
        : AppColors.statusSuccess;

    return GestureDetector(
      onTap: enabled ? () => onChanged(network) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: showLabels ? AppSpacing.md : AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: isSelected
              ? Border.all(
                  color: color,
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              network.emoji,
              style: TextStyle(
                fontSize: 16,
                color: enabled
                    ? (isSelected ? color : AppColors.textSecondary)
                    : AppColors.textMuted,
              ),
            ),
            if (showLabels) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                network.displayName,
                style: AppTextStyles.label.copyWith(
                  color: enabled
                      ? (isSelected ? color : AppColors.textSecondary)
                      : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple network toggle button
class NetworkToggleButton extends StatelessWidget {
  final MagicBlockNetwork network;
  final ValueChanged<MagicBlockNetwork> onTap;
  final bool enabled;

  const NetworkToggleButton({
    super.key,
    required this.network,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDevnet = network == MagicBlockNetwork.devnet;
    final color = isDevnet ? AppColors.statusWarning : AppColors.statusSuccess;

    return GestureDetector(
      onTap: enabled ? () => onTap(isDevnet ? MagicBlockNetwork.mainnet : MagicBlockNetwork.devnet) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              network.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              network.displayName,
              style: AppTextStyles.label.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.expand_more,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

/// Network status card
class NetworkStatusCard extends StatelessWidget {
  final MagicBlockNetwork network;
  final int? currentSlot;
  final bool isConnected;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const NetworkStatusCard({
    super.key,
    required this.network,
    this.currentSlot,
    this.isConnected = true,
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDevnet = network == MagicBlockNetwork.devnet;
    final color = isDevnet ? AppColors.statusWarning : AppColors.statusSuccess;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: isConnected ? color.withValues(alpha: 0.3) : AppColors.statusError.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? color : AppColors.statusError,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? color : AppColors.statusError).withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Network info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      network.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      network.displayName,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (currentSlot != null)
                  Text(
                    'Slot: $currentSlot',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // Refresh button
          if (onRefresh != null)
            GestureDetector(
              onTap: isRefreshing ? null : onRefresh,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: isRefreshing ? 0.5 : 0,
                child: const Icon(
                  Icons.refresh,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Network selector with full details
class NetworkSelector extends StatelessWidget {
  final MagicBlockNetwork network;
  final ValueChanged<MagicBlockNetwork> onChanged;
  final bool enabled;

  const NetworkSelector({
    super.key,
    required this.network,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Network',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...MagicBlockNetwork.values.map((n) => _buildNetworkOption(n)),
      ],
    );
  }

  Widget _buildNetworkOption(MagicBlockNetwork network) {
    final isSelected = this.network == network;
    final isDevnet = network == MagicBlockNetwork.devnet;
    final color = isDevnet ? AppColors.statusWarning : AppColors.statusSuccess;

    return GestureDetector(
      onTap: enabled ? () => onChanged(network) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: isSelected ? color : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : AppColors.backgroundTertiary,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.textPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        network.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        network.displayName,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isDevnet
                        ? 'Test network with fake SOL'
                        : 'Main network with real SOL',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Network badge - compact display
class NetworkBadge extends StatelessWidget {
  final MagicBlockNetwork network;

  const NetworkBadge({
    super.key,
    required this.network,
  });

  @override
  Widget build(BuildContext context) {
    final isDevnet = network == MagicBlockNetwork.devnet;
    final color = isDevnet ? AppColors.statusWarning : AppColors.statusSuccess;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            network.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            network.displayName.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// RPC Endpoint display
class RpcEndpointDisplay extends StatelessWidget {
  final String endpoint;
  final bool isMagicBlock;
  final VoidCallback? onCopy;

  const RpcEndpointDisplay({
    super.key,
    required this.endpoint,
    this.isMagicBlock = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: isMagicBlock ? AppColors.brandPrimary.withValues(alpha: 0.3) : AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isMagicBlock ? '⚡' : '🌐',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isMagicBlock ? 'MagicBlock Router' : 'RPC Endpoint',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (onCopy != null)
                GestureDetector(
                  onTap: onCopy,
                  child: const Icon(
                    Icons.copy,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            endpoint,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'Courier',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
