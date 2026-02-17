import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Animated Glow Widget
///
/// Provides pulse glow effect for interactive elements.
/// Can be used as a decorative background or overlay.
class AnimatedGlow extends StatefulWidget {
  final Widget? child;
  final Color? glowColor;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;
  final Curve curve;
  final double? size;
  final GlowShape shape;
  final bool enableBlur;
  final double blurSigma;

  const AnimatedGlow({
    super.key,
    this.child,
    this.glowColor,
    this.minOpacity = 0.2,
    this.maxOpacity = 0.6,
    this.duration = AppAnimations.pulse,
    this.curve = Curves.easeInOut,
    this.size,
    this.shape = GlowShape.circle,
    this.enableBlur = true,
    this.blurSigma = 20,
  });

  @override
  State<AnimatedGlow> createState() => _AnimatedGlowState();
}

class _AnimatedGlowState extends State<AnimatedGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.glowColor ?? AppColors.brandPrimary;

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: effectiveColor,
              shape: widget.shape == GlowShape.circle
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius: widget.shape == GlowShape.roundedRectangle
                  ? BorderRadius.circular(AppBorderRadius.lg)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: _opacityAnimation.value),
                  blurRadius: widget.blurSigma,
                  spreadRadius: widget.blurSigma / 2,
                ),
              ],
            ),
            child: widget.enableBlur
                ? BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blurSigma,
                      sigmaY: widget.blurSigma,
                    ),
                    child: child,
                  )
                : child,
          ),
        );
      },
    );
  }
}

/// Glow shape options
enum GlowShape {
  circle,
  rectangle,
  roundedRectangle,
}

/// Pulsing glow container for interactive elements
class PulseGlowContainer extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final double glowIntensity;
  final Duration duration;
  final bool isAnimating;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const PulseGlowContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.glowIntensity = 0.3,
    this.duration = AppAnimations.pulse,
    this.isAnimating = true,
    this.borderRadius,
    this.padding,
  });

  @override
  State<PulseGlowContainer> createState() => _PulseGlowContainerState();
}

class _PulseGlowContainerState extends State<PulseGlowContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.isAnimating) {
      _controller.repeat(reverse: true);
    }

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(
      begin: widget.glowIntensity,
      end: widget.glowIntensity * 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(PulseGlowContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.glowColor ?? AppColors.brandPrimary;
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(AppBorderRadius.lg);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: effectiveBorderRadius,
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha: _opacityAnimation.value),
                blurRadius: 20 * _scaleAnimation.value,
                spreadRadius: 5 * _scaleAnimation.value,
              ),
            ],
          ),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: effectiveColor.withValues(alpha: _opacityAnimation.value * 0.5),
                width: 1,
              ),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Status glow widget for showing connection/active states
class StatusGlow extends StatefulWidget {
  final bool isActive;
  final StatusGlowType type;
  final double size;

  const StatusGlow({
    super.key,
    required this.isActive,
    this.type = StatusGlowType.active,
    this.size = 8,
  });

  @override
  State<StatusGlow> createState() => _StatusGlowState();
}

class _StatusGlowState extends State<StatusGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.pulse,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color glowColor;
    switch (widget.type) {
      case StatusGlowType.success:
        glowColor = AppColors.statusSuccess;
        break;
      case StatusGlowType.error:
        glowColor = AppColors.statusError;
        break;
      case StatusGlowType.warning:
        glowColor = AppColors.statusWarning;
        break;
      case StatusGlowType.active:
        glowColor = AppColors.brandPrimary;
        break;
    }

    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isActive)
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Container(
                  width: widget.size * _scaleAnimation.value,
                  height: widget.size * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    color: glowColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: glowColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Status glow types
enum StatusGlowType {
  active,
  success,
  error,
  warning,
}

/// Connection indicator with animated glow
class ConnectionIndicator extends StatefulWidget {
  final ConnectionStatus status;
  final String? label;

  const ConnectionIndicator({
    super.key,
    required this.status,
    this.label,
  });

  @override
  State<ConnectionIndicator> createState() => _ConnectionIndicatorState();
}

class _ConnectionIndicatorState extends State<ConnectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.pulse,
      vsync: this,
    );

    if (_shouldAnimate()) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      if (_shouldAnimate()) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  bool _shouldAnimate() {
    return widget.status == ConnectionStatus.connecting ||
        widget.status == ConnectionStatus.active;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;

    switch (widget.status) {
      case ConnectionStatus.connected:
        statusColor = AppColors.statusSuccess;
        statusLabel = 'Connected';
        break;
      case ConnectionStatus.connecting:
        statusColor = AppColors.statusWarning;
        statusLabel = 'Connecting';
        break;
      case ConnectionStatus.active:
        statusColor = AppColors.brandPrimary;
        statusLabel = 'Active';
        break;
      case ConnectionStatus.disconnected:
        statusColor = AppColors.textMuted;
        statusLabel = 'Disconnected';
        break;
    }

    final displayLabel = widget.label ?? statusLabel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_shouldAnimate())
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 8 + (4 * _controller.value),
                height: 8 + (4 * _controller.value),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.3 - (0.2 * _controller.value)),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        Container(
          width: 8,
          height: 8,
          margin: _shouldAnimate() ? const EdgeInsets.only(left: 4) : null,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.5),
                blurRadius: _shouldAnimate() ? 8 : 4,
                spreadRadius: _shouldAnimate() ? 2 : 0,
              ),
            ],
          ),
        ),
        if (displayLabel.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            displayLabel,
            style: AppTextStyles.labelSmall.copyWith(color: statusColor),
          ),
        ],
      ],
    );
  }
}

/// Connection status enum
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  active,
}
