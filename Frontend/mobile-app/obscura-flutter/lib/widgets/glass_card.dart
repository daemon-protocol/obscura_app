import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Glass Card Component
///
/// A neo-noir glassmorphism card with:
/// - Blur backdrop effect
/// - Subtle gradient border
/// - Inner glow effect
/// - Configurable elevation and padding
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final bool borderEnabled;
  final bool glowEnabled;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.gradient,
    this.borderEnabled = true,
    this.glowEnabled = false,
    this.borderColor,
    this.borderWidth = 1.0,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppBorderRadius.lg);

    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.glassGradient,
        borderRadius: effectiveBorderRadius,
        border: borderEnabled
            ? Border.all(
                color: borderColor ?? AppColors.border.glass,
                width: borderWidth,
              )
            : null,
        boxShadow: glowEnabled ? AppShadows.glass : null,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              gradient: isHighlighted
                  ? AppGradients.glassTopHighlight
                  : null,
            ),
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          splashColor: AppColors.brandGlow,
          highlightColor: AppColors.brand.glowSubtle,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Variant of GlassCard with bottom highlight gradient
class GlassCardBottomHighlight extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassCardBottomHighlight({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderRadius: borderRadius,
      onTap: onTap,
      isHighlighted: true,
      child: child,
    );
  }
}

/// Compact glass card for smaller UI elements
class GlassCardCompact extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glowEnabled;

  const GlassCardCompact({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glowEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      glowEnabled: glowEnabled,
      onTap: onTap,
      child: child,
    );
  }
}

/// Glass card with purple tint for brand-aligned elements
class GlassCardBrand extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassCardBrand({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      gradient: AppGradients.glassPurple,
      borderColor: AppColors.brand.glowSubtle,
      glowEnabled: true,
      onTap: onTap,
      child: child,
    );
  }
}
