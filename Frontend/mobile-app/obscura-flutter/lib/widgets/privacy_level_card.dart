import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'glass_card.dart';

/// Privacy Level Card Component - Neo-Noir Edition
///
/// Redesigned with glassmorphism, better icons, and enhanced visual design.
/// Shows privacy options with icons and descriptions in an elegant card format.
class PrivacyLevelCard extends StatefulWidget {
  final String icon;
  final String name;
  final String description;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? accentColor;

  const PrivacyLevelCard({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    this.isSelected = false,
    this.onTap,
    this.accentColor,
  });

  @override
  State<PrivacyLevelCard> createState() => _PrivacyLevelCardState();
}

class _PrivacyLevelCardState extends State<PrivacyLevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _selectionController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PrivacyLevelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = widget.accentColor ?? AppColors.brandPrimary;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _selectionController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: AppAnimations.fast,
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        effectiveAccentColor.withOpacity(0.2),
                        effectiveAccentColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : AppGradients.glassGradient,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(
                color: widget.isSelected
                    ? effectiveAccentColor.withOpacity(
                        0.5 + (0.5 * _selectionController.value),
                      )
                    : AppColors.border.subtle,
                width: widget.isSelected ? 1.5 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: effectiveAccentColor.withOpacity(
                          0.3 * _selectionController.value,
                        ),
                        blurRadius: 16,
                        spreadRadius: -4,
                      ),
                      AppShadows.sm,
                    ]
                  : [AppShadows.sm],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              child: Stack(
                children: [
                  // Glass effect
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        ),
                      ),
                    ),
                  ),
                  // Selection indicator
                  if (widget.isSelected)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              effectiveAccentColor.withOpacity(0.8),
                              effectiveAccentColor.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _buildIcon(effectiveAccentColor),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.name,
                          style: AppTextStyles.label.copyWith(
                            color: widget.isSelected
                                ? AppColors.textPrimary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.description,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: widget.isSelected
                                ? AppColors.textSecondary
                                : AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon(Color accentColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: widget.isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.3),
                  accentColor.withOpacity(0.1),
                ],
              )
            : null,
        color: widget.isSelected ? null : AppColors.background.card,
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: widget.isSelected
              ? accentColor.withOpacity(0.5)
              : AppColors.border.subtle,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          widget.icon,
          style: TextStyle(
            fontSize: 20,
            color: widget.isSelected ? accentColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Privacy level selector with horizontal scroll
class PrivacyLevelSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<PrivacyLevel> levels;

  const PrivacyLevelSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.levels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: levels.asMap().entries.map((entry) {
        final index = entry.key;
        final level = entry.value;
        final isSelected = index == selectedIndex;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < levels.length - 1 ? AppSpacing.xs : 0,
            ),
            child: PrivacyLevelCard(
              icon: level.icon,
              name: level.name,
              description: level.description,
              isSelected: isSelected,
              onTap: () => onSelected(index),
              accentColor: level.color,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Privacy level data model
class PrivacyLevel {
  final String icon;
  final String name;
  final String description;
  final Color color;

  const PrivacyLevel({
    required this.icon,
    required this.name,
    required this.description,
    required this.color,
  });

  static const List<PrivacyLevel> defaults = [
    PrivacyLevel(
      icon: '🛡️',
      name: 'Shielded',
      description: 'Maximum privacy',
      color: Color(0xFF10B981), // Green
    ),
    PrivacyLevel(
      icon: '📋',
      name: 'Compliant',
      description: 'With viewing keys',
      color: Color(0xFF9D4EDD), // Purple
    ),
    PrivacyLevel(
      icon: '🔓',
      name: 'Transparent',
      description: 'Debug mode',
      color: Color(0xFF6366F1), // Indigo
    ),
  ];
}

/// Compact privacy level pill
class PrivacyLevelPill extends StatelessWidget {
  final PrivacyLevel level;
  final bool isSelected;
  final VoidCallback? onTap;

  const PrivacyLevelPill({
    super.key,
    required this.level,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    level.color.withOpacity(0.3),
                    level.color.withOpacity(0.1),
                  ],
                )
              : AppGradients.glassGradient,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? level.color : AppColors.border.subtle,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              level.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              level.name,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? level.color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Privacy selector card for detailed selection
class PrivacySelectorCard extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;
  final IconData? icon;

  const PrivacySelectorCard({
    super.key,
    required this.title,
    required this.description,
    required this.children,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppGradients.actionGradient,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}
