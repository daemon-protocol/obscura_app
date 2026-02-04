import 'package:flutter/material.dart';
import '../models/magic_block_models.dart';
import '../theme/theme.dart';

/// Delegation Status Widget
///
/// Displays the current delegation state of accounts with visual indicators.
class DelegationStatusWidget extends StatelessWidget {
  final DelegationStatus status;
  final VoidCallback? onDelegate;
  final VoidCallback? onUndelegate;
  final VoidCallback? onCommit;
  final bool showActions;

  const DelegationStatusWidget({
    super.key,
    required this.status,
    this.onDelegate,
    this.onUndelegate,
    this.onCommit,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                _getStatusEmoji(),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _getStatusTitle(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (status.validator != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status.validatorRegion != null) ...[
                        Text(
                          _getRegionFlag(status.validatorRegion!),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        'Fast Mode',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Account address
          const SizedBox(height: AppSpacing.sm),
          Text(
            _formatAddress(status.account),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontFamily: 'Courier',
            ),
          ),

          // Details
          if (status.state.isDelegated) ...[
            const SizedBox(height: AppSpacing.md),
            _buildDelegatedDetails(),
          ],

          // Actions
          if (showActions) ...[
            const SizedBox(height: AppSpacing.md),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildDelegatedDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Validator info
        if (status.validator != null)
          _buildDetailRow(
            'Validator',
            _formatAddress(status.validator!),
          ),

        // Delegation time
        if (status.delegatedAt != null)
          _buildDetailRow(
            'Delegated',
            _formatDuration(status.delegatedAt!),
          ),

        // Last commit
        if (status.lastCommitSlot != null)
          _buildDetailRow(
            'Last Commit',
            'Slot ${status.lastCommitSlot}',
          ),

        // Estimated latency
        if (status.estimatedLatency != null)
          _buildDetailRow(
            'Latency',
            '${status.estimatedLatency}ms',
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    switch (status.state) {
      case DelegationState.notDelegated:
        if (onDelegate != null) {
          return _buildActionButton(
            'Delegate for Fast Mode',
            Icons.flash_on,
            AppColors.brandPrimary,
            onDelegate!,
          );
        }
        break;

      case DelegationState.delegated:
        return Row(
          children: [
            if (onCommit != null)
              Expanded(
                child: _buildActionButton(
                  'Commit',
                  Icons.cloud_upload,
                  AppColors.brandSecondary,
                  onCommit!,
                ),
              ),
            if (onCommit != null && onUndelegate != null)
              const SizedBox(width: AppSpacing.sm),
            if (onUndelegate != null)
              Expanded(
                child: _buildActionButton(
                  'Undelegate',
                  Icons.lock_open,
                  AppColors.textSecondary,
                  onUndelegate!,
                ),
              ),
          ],
        );

      case DelegationState.pendingCommit:
        if (onCommit != null) {
          return _buildActionButton(
            'Commit Changes',
            Icons.cloud_upload,
            AppColors.brandSecondary,
            onCommit!,
          );
        }
        break;

      case DelegationState.pendingUndelegation:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Undelegating...',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusEmoji() {
    return status.state.emoji;
  }

  String _getStatusTitle() {
    return status.state.displayName;
  }

  Color _getBackgroundColor() {
    switch (status.state) {
      case DelegationState.notDelegated:
        return AppColors.backgroundCard;
      case DelegationState.delegated:
        return const Color(0x1010B981); // rgba(16, 185, 129, 0.1)
      case DelegationState.pendingCommit:
        return const Color(0x10F59E0B); // rgba(245, 158, 11, 0.1)
      case DelegationState.pendingUndelegation:
        return const Color(0x10F97316); // rgba(249, 115, 22, 0.1)
    }
  }

  Color _getBorderColor() {
    switch (status.state) {
      case DelegationState.notDelegated:
        return AppColors.borderDefault;
      case DelegationState.delegated:
        return const Color(0x3010B981); // rgba(16, 185, 129, 0.3)
      case DelegationState.pendingCommit:
        return const Color(0x30F59E0B); // rgba(245, 158, 11, 0.3)
      case DelegationState.pendingUndelegation:
        return const Color(0x30F97316); // rgba(249, 115, 22, 0.3)
    }
  }

  String _formatAddress(String address) {
    if (address.length < 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatDuration(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getRegionFlag(String region) {
    switch (region.toLowerCase()) {
      case 'asia':
        return '🌏';
      case 'eu':
      case 'europe':
        return '🇪🇺';
      case 'us':
      case 'usa':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }
}

/// Compact delegation indicator
class DelegationIndicator extends StatelessWidget {
  final DelegationStatus status;
  final VoidCallback? onTap;

  const DelegationIndicator({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getStatusEmoji(),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              status.state == DelegationState.delegated
                  ? 'Fast'
                  : status.state.name.substring(0, 1).toUpperCase() + status.state.name.substring(1),
              style: AppTextStyles.caption.copyWith(
                color: _getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status.state) {
      case DelegationState.notDelegated:
        return AppColors.backgroundTertiary;
      case DelegationState.delegated:
        return const Color(0x2010B981);
      case DelegationState.pendingCommit:
        return const Color(0x20F59E0B);
      case DelegationState.pendingUndelegation:
        return const Color(0x20F97316);
    }
  }

  Color _getBorderColor() {
    switch (status.state) {
      case DelegationState.notDelegated:
        return AppColors.borderDefault;
      case DelegationState.delegated:
        return const Color(0x4010B981);
      case DelegationState.pendingCommit:
        return const Color(0x40F59E0B);
      case DelegationState.pendingUndelegation:
        return const Color(0x40F97316);
    }
  }

  Color _getTextColor() {
    switch (status.state) {
      case DelegationState.notDelegated:
        return AppColors.textSecondary;
      case DelegationState.delegated:
        return AppColors.statusSuccess;
      case DelegationState.pendingCommit:
        return AppColors.statusWarning;
      case DelegationState.pendingUndelegation:
        return const Color(0xFFF97316);
    }
  }

  String _getStatusEmoji() {
    return status.state.emoji;
  }
}

/// Multiple delegation statuses widget
class DelegationListWidget extends StatelessWidget {
  final List<DelegationStatus> statuses;
  final Function(String account)? onDelegate;
  final Function(String account)? onUndelegate;
  final Function(String account)? onCommit;

  const DelegationListWidget({
    super.key,
    required this.statuses,
    this.onDelegate,
    this.onUndelegate,
    this.onCommit,
  });

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Text(
              '⚪',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No Delegated Accounts',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Delegate accounts for Fast Mode transactions',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delegated Accounts (${statuses.length})',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...statuses.map((status) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: DelegationStatusWidget(
                status: status,
                onDelegate: onDelegate != null ? () => onDelegate!(status.account) : null,
                onUndelegate: onUndelegate != null ? () => onUndelegate!(status.account) : null,
                onCommit: onCommit != null ? () => onCommit!(status.account) : null,
              ),
            )),
      ],
    );
  }
}
