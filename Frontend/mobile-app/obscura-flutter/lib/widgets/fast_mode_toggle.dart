import 'package:flutter/material.dart';
import '../models/magic_block_models.dart';
import '../theme/theme.dart';

/// Fast Mode Toggle Widget
///
/// Switch between "Standard" (base layer) and "Fast Mode" (ER) for transactions.
class FastModeToggle extends StatelessWidget {
  final ExecutionMode mode;
  final ValueChanged<ExecutionMode> onChanged;
  final bool enabled;
  final bool showLabels;

  const FastModeToggle({
    super.key,
    required this.mode,
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
        children: ExecutionMode.values.map((m) {
          final isSelected = mode == m;
          return _buildModeButton(m, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildModeButton(ExecutionMode mode, bool isSelected) {
    final modeColor = _getModeColor(mode);
    final modeGradient = _getModeGradient(mode);

    return GestureDetector(
      onTap: enabled ? () => onChanged(mode) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: showLabels ? AppSpacing.md : AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected && modeGradient != null ? modeGradient : null,
          color: isSelected && modeGradient == null
              ? modeColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: isSelected
              ? Border.all(
                  color: modeColor,
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mode.emoji,
              style: TextStyle(
                fontSize: 14,
                color: enabled
                    ? (isSelected ? modeColor : AppColors.textSecondary)
                    : AppColors.textMuted,
              ),
            ),
            if (showLabels) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                mode.shortName,
                style: AppTextStyles.label.copyWith(
                  color: enabled
                      ? (isSelected ? modeColor : AppColors.textSecondary)
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

  Color _getModeColor(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.standard:
        return AppColors.textSecondary;
      case ExecutionMode.fast:
        return AppColors.brandPrimary;
      case ExecutionMode.private:
        return AppColors.statusSuccess;
      case ExecutionMode.compressed:
        return AppColors.brandSecondary;
      case ExecutionMode.fastCompressed:
        return const Color(0xFF6366F1); // Indigo/Blue
      case ExecutionMode.privateCompressed:
        return const Color(0xFF10B981); // Green
    }
  }

  Gradient? _getModeGradient(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.fastCompressed:
        return AppGradients.blueToPurple;
      case ExecutionMode.privateCompressed:
        return AppGradients.greenToPurple;
      default:
        return null;
    }
  }
}

/// Simple Fast Mode Switch (toggle between Standard and Fast only)
class FastModeSwitch extends StatelessWidget {
  final bool isFastMode;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const FastModeSwitch({
    super.key,
    required this.isFastMode,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!isFastMode) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isFastMode ? AppGradients.purpleToBlue : null,
          color: isFastMode ? null : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: Border.all(
            color: isFastMode ? AppColors.brandPrimary : AppColors.borderDefault,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                isFastMode ? '⚡' : '⏱️',
                key: ValueKey(isFastMode),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isFastMode ? 'Fast Mode' : 'Standard',
              style: AppTextStyles.label.copyWith(
                color: isFastMode ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isFastMode) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
                child: Text(
                  '~50ms',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Execution Mode Selector with descriptions
class ExecutionModeSelector extends StatelessWidget {
  final ExecutionMode mode;
  final ValueChanged<ExecutionMode> onChanged;
  final bool enabled;

  const ExecutionModeSelector({
    super.key,
    required this.mode,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Execution Mode',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...ExecutionMode.values.map((m) => _buildModeOption(m)),
      ],
    );
  }

  Widget _buildModeOption(ExecutionMode mode) {
    final isSelected = this.mode == mode;
    final color = _getModeColor(mode);

    return GestureDetector(
      onTap: enabled ? () => onChanged(mode) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.backgroundCard,
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
                  ? Icon(
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
                        mode.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        mode.displayName,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    mode.description,
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

  Color _getModeColor(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.standard:
        return AppColors.textSecondary;
      case ExecutionMode.fast:
        return AppColors.brandPrimary;
      case ExecutionMode.private:
        return AppColors.statusSuccess;
      case ExecutionMode.compressed:
        return AppColors.brandSecondary;
      case ExecutionMode.fastCompressed:
        return const Color(0xFF6366F1); // Indigo/Blue
      case ExecutionMode.privateCompressed:
        return const Color(0xFF10B981); // Green
    }
  }

  Gradient? _getModeGradient(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.fastCompressed:
        return AppGradients.blueToPurple;
      case ExecutionMode.privateCompressed:
        return AppGradients.greenToPurple;
      default:
        return null;
    }
  }
}

/// Speed comparison widget
class SpeedComparisonWidget extends StatelessWidget {
  final ExecutionMode mode;

  const SpeedComparisonWidget({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Speed',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSpeedBar(context, 'Standard', 400, AppColors.textSecondary, mode == ExecutionMode.standard),
          const SizedBox(height: AppSpacing.sm),
          _buildSpeedBar(context, 'Fast (ER)', 50, AppColors.brandPrimary, mode == ExecutionMode.fast),
          const SizedBox(height: AppSpacing.sm),
          _buildSpeedBar(context, 'Compressed', 100, AppColors.brandSecondary, mode == ExecutionMode.compressed),
          const SizedBox(height: AppSpacing.sm),
          _buildSpeedBar(context, 'Private (PER)', 75, AppColors.statusSuccess, mode == ExecutionMode.private),
          const SizedBox(height: AppSpacing.sm),
          _buildSpeedBar(context, 'Fast+Comp', 60, const Color(0xFF6366F1), mode == ExecutionMode.fastCompressed),
          const SizedBox(height: AppSpacing.sm),
          _buildSpeedBar(context, 'Priv+Comp', 85, const Color(0xFF10B981), mode == ExecutionMode.privateCompressed),
        ],
      ),
    );
  }

  Widget _buildSpeedBar(BuildContext context, String label, int ms, Color color, bool isSelected) {
    // Normalize width: 400ms = full width, 50ms = 1/8 width
    final widthFactor = ms / 400.0;

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? color : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                width: widthFactor * MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 50,
          child: Text(
            '${ms}ms',
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? color : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Compact badge showing current execution mode
class ExecutionModeBadge extends StatelessWidget {
  final ExecutionMode mode;

  const ExecutionModeBadge({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getModeColor(mode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
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
        children: [
          Text(
            mode.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            mode.shortName,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getModeColor(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.standard:
        return AppColors.textSecondary;
      case ExecutionMode.fast:
        return AppColors.brandPrimary;
      case ExecutionMode.private:
        return AppColors.statusSuccess;
      case ExecutionMode.compressed:
        return AppColors.brandSecondary;
      case ExecutionMode.fastCompressed:
        return const Color(0xFF6366F1); // Indigo/Blue
      case ExecutionMode.privateCompressed:
        return const Color(0xFF10B981); // Green
    }
  }

  Gradient? _getModeGradient(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.fastCompressed:
        return AppGradients.blueToPurple;
      case ExecutionMode.privateCompressed:
        return AppGradients.greenToPurple;
      default:
        return null;
    }
  }
}

/// Hybrid Mode Badge - displays combined mode badges with gradients
class HybridModeBadge extends StatelessWidget {
  final ExecutionMode mode;
  final bool showDescription;

  const HybridModeBadge({
    super.key,
    required this.mode,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!mode.isHybrid) {
      return ExecutionModeBadge(mode: mode);
    }

    final gradient = _getHybridGradient(mode);
    final color = _getHybridColor(mode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mode.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          if (showDescription) ...[
            const SizedBox(width: 4),
            Text(
              mode.shortName,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Gradient _getHybridGradient(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.fastCompressed:
        return AppGradients.fastCompressedBadge;
      case ExecutionMode.privateCompressed:
        return AppGradients.privateCompressedBadge;
      default:
        return AppGradients.primary;
    }
  }

  Color _getHybridColor(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.fastCompressed:
        return const Color(0xFF6366F1);
      case ExecutionMode.privateCompressed:
        return const Color(0xFF10B981);
      default:
        return AppColors.brandPrimary;
    }
  }
}

/// Hybrid Balance Display - shows regular + compressed balance breakdown
class HybridBalanceDisplay extends StatelessWidget {
  final double regularBalance;
  final double compressedBalance;
  final ExecutionMode mode;

  const HybridBalanceDisplay({
    super.key,
    required this.regularBalance,
    required this.compressedBalance,
    this.mode = ExecutionMode.standard,
  });

  double get totalBalance => regularBalance + compressedBalance;

  @override
  Widget build(BuildContext context) {
    final showBreakdown = mode.usesCompression && compressedBalance > 0;

    if (!showBreakdown) {
      return _buildSingleBalance(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${totalBalance.toStringAsFixed(4)} SOL',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (mode.isHybrid) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                mode.emoji,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBalanceChip(
              'Regular: ${regularBalance.toStringAsFixed(3)}',
              AppColors.brandPrimary,
            ),
            const SizedBox(width: AppSpacing.xs),
            _buildBalanceChip(
              'Compressed: ${compressedBalance.toStringAsFixed(3)}',
              const Color(0xFF6366F1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleBalance(BuildContext context) {
    return Text(
      '${regularBalance.toStringAsFixed(4)} SOL',
      style: AppTextStyles.label.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBalanceChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Cost comparison widget for hybrid modes
class HybridCostComparison extends StatelessWidget {
  final ExecutionMode mode;

  const HybridCostComparison({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    if (!mode.isHybrid) {
      return const SizedBox.shrink();
    }

    final costSavings = _getCostSavingsPercentage(mode);
    final color = _getModeColor(mode);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: _getBadgeGradient(mode),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.savings_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '~${costSavings}x cheaper with compression',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int _getCostSavingsPercentage(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.fastCompressed:
      case ExecutionMode.privateCompressed:
        return 1000;
      default:
        return 0;
    }
  }

  Color _getModeColor(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.fastCompressed:
        return const Color(0xFF6366F1);
      case ExecutionMode.privateCompressed:
        return const Color(0xFF10B981);
      default:
        return AppColors.brandPrimary;
    }
  }

  Gradient _getBadgeGradient(ExecutionMode mode) {
    switch (mode) {
      case ExecutionMode.fastCompressed:
        return AppGradients.fastCompressedBadge;
      case ExecutionMode.privateCompressed:
        return AppGradients.privateCompressedBadge;
      default:
        return AppGradients.primary;
    }
  }
}
