import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'glass_card.dart';

/// Premium Button Component
///
/// Neo-noir styled button with three variants:
/// - Primary: Gradient background with glow
/// - Secondary: Glass with border
/// - Ghost: Transparent with blur
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PremiumButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;
  final bool isLoading;
  final Widget? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool glowEnabled;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = PremiumButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
    this.isLoading = false,
    this.icon,
    this.trailing,
    this.padding,
    this.borderRadius,
    this.glowEnabled = true,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final effectiveBorderRadius = widget.borderRadius ??
        BorderRadius.circular(_getBorderRadius());

    final buttonChild = _buildButtonContent(effectiveBorderRadius, isEnabled);

    if (widget.fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonChild,
      );
    }

    return buttonChild;
  }

  Widget _buildButtonContent(BorderRadius borderRadius, bool isEnabled) {
    final content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          _buildLoadingIndicator(),
          const SizedBox(width: AppSpacing.sm),
        ] else if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.text,
          style: _getTextStyle(),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          widget.trailing!,
        ],
      ],
    );

    switch (widget.variant) {
      case PremiumButtonVariant.primary:
        return _buildPrimaryButton(content, borderRadius, isEnabled);

      case PremiumButtonVariant.secondary:
        return _buildSecondaryButton(content, borderRadius, isEnabled);

      case PremiumButtonVariant.ghost:
        return _buildGhostButton(content, borderRadius, isEnabled);
    }
  }

  Widget _buildPrimaryButton(
    Widget content,
    BorderRadius borderRadius,
    bool isEnabled,
  ) {
    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: widget.padding ?? _getPadding(),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? AppGradients.actionGradientGlow
                : AppGradients.actionGradientSubtle,
            borderRadius: borderRadius,
            boxShadow: widget.glowEnabled && isEnabled
                ? AppShadows.glowStrong
                : [AppShadows.sm],
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    Widget content,
    BorderRadius borderRadius,
    bool isEnabled,
  ) {
    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GlassCard(
          padding: widget.padding ?? _getPadding(),
          borderRadius: borderRadius,
          borderEnabled: true,
          glowEnabled: widget.glowEnabled && isEnabled && _isPressed,
          gradient: AppGradients.glassPurple,
          borderColor: isEnabled
              ? AppColors.brand.primary
              : AppColors.border.subtle,
          child: content,
        ),
      ),
    );
  }

  Widget _buildGhostButton(
    Widget content,
    BorderRadius borderRadius,
    bool isEnabled,
  ) {
    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              padding: widget.padding ?? _getPadding(),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: isEnabled
                      ? AppColors.border.glass
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _getTextStyle() {
    final baseStyle = widget.size == ButtonSize.large
        ? AppTextStyles.button
        : widget.size == ButtonSize.small
            ? AppTextStyles.buttonSmall
            : AppTextStyles.button;

    return baseStyle.copyWith(
      color: widget.variant == PremiumButtonVariant.secondary ||
              widget.variant == PremiumButtonVariant.ghost
          ? AppColors.textPrimary
          : Colors.white,
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ButtonSize.large:
        return AppBorderRadius.lg.toDouble();
      case ButtonSize.medium:
        return AppBorderRadius.md.toDouble();
      case ButtonSize.small:
        return AppBorderRadius.sm.toDouble();
    }
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: _getLoadingSize(),
      height: _getLoadingSize(),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ButtonSize.large:
        return 20;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.small:
        return 14;
    }
  }
}

/// Premium button variants
enum PremiumButtonVariant {
  /// Gradient background with glow
  primary,

  /// Glass with border
  secondary,

  /// Transparent with blur
  ghost,
}

/// Button sizes
enum ButtonSize {
  small,
  medium,
  large,
}

/// Icon-only premium button
class PremiumIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final PremiumButtonVariant variant;
  final ButtonSize size;
  final bool glowEnabled;
  final String? tooltip;

  const PremiumIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = PremiumButtonVariant.secondary,
    this.size = ButtonSize.medium,
    this.glowEnabled = true,
    this.tooltip,
  });

  @override
  State<PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<PremiumIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.pulse,
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = _getIconSize();
    final padding = _getPadding();
    final isEnabled = widget.onPressed != null;

    Widget button = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: widget.variant == PremiumButtonVariant.primary
            ? AppGradients.actionGradient
            : AppGradients.glassGradient,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: widget.variant != PremiumButtonVariant.primary
            ? Border.all(color: AppColors.border.glass)
            : null,
        boxShadow: widget.glowEnabled && isEnabled
            ? [AppShadows.glowSubtle]
            : null,
      ),
      child: Icon(
        widget.icon,
        size: iconSize,
        color: widget.variant == PremiumButtonVariant.primary
            ? Colors.white
            : AppColors.textPrimary,
      ),
    );

    if (isEnabled) {
      button = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          child: button,
        ),
      );
    }

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.large:
        return 24;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.small:
        return 16;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.large:
        return const EdgeInsets.all(AppSpacing.md);
      case ButtonSize.medium:
        return const EdgeInsets.all(AppSpacing.sm);
      case ButtonSize.small:
        return const EdgeInsets.all(AppSpacing.xs);
    }
  }
}
