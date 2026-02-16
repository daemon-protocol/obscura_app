import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'glass_card.dart';

/// Action Card Component - Neo-Noir Edition
///
/// Redesigned with glassmorphism effect, subtle hover glow animation,
/// and better visual hierarchy.
class ActionCard extends StatefulWidget {
  final String icon;
  final String title;
  final String description;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool locked;
  final Widget? customIcon;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
    this.locked = false,
    this.customIcon,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locked) {
      return _buildLockedCard();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: AppAnimations.fast,
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.gradient.colors.first.withOpacity(0.9),
                widget.gradient.colors.last.withOpacity(0.7),
              ],
              stops: widget.gradient.stops,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: [
              // Soft shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              // Glow effect on hover
              if (_isHovered)
                BoxShadow(
                  color: widget.gradient.colors.first.withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            child: Stack(
              children: [
                // Background glass effect
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.glassGradient,
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                    ),
                  ),
                ),
                // Top highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIcon(),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.title,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.description,
                        style: AppTextStyles.bodySmall.copyWith(
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
      },
    );
  }

  Widget _buildLockedCard() {
    return Opacity(
      opacity: 0.5,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.actionGradientSubtle,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: AppColors.border.subtle,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(isLocked: true),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: AppColors.statusWarning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Connect wallet to use',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.statusWarning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon({bool isLocked = false}) {
    if (widget.customIcon != null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        child: widget.customIcon,
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isLocked
            ? AppColors.background.card
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: Colors.white.withOpacity(isLocked ? 0.05 : 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          widget.icon,
          style: TextStyle(
            fontSize: 24,
            color: isLocked ? AppColors.textMuted : null,
          ),
        ),
      ),
    );
  }
}

/// Compact action card for smaller layouts
class ActionCardCompact extends StatelessWidget {
  final String icon;
  final String title;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool locked;

  const ActionCardCompact({
    super.key,
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCardCompact(
      onTap: locked ? null : onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      glowEnabled: !locked,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.label.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Glass action card with icon
class GlassActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool locked;

  const GlassActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: locked ? null : onTap,
      glowEnabled: !locked,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.actionGradient,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (locked)
            Icon(
              Icons.lock_outline,
              size: 16,
              color: AppColors.statusWarning,
            )
        else
          Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
