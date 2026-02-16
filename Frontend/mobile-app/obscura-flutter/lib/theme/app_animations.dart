import 'package:flutter/material.dart';

/// Neo-Noir Animation Constants
///
/// Provides consistent timing and easing curves for animations
/// throughout the app. The neo-noir aesthetic favors smooth,
/// elegant transitions that feel luxurious and refined.
class AppAnimations {
  AppAnimations._();

  // ============================================================
  // DURATIONS
  // ============================================================

  /// Instant animation (for micro-interactions)
  static const instant = Duration(milliseconds: 100);

  /// Fast animation (for quick transitions)
  static const fast = Duration(milliseconds: 200);

  /// Medium animation (default duration)
  static const medium = Duration(milliseconds: 350);

  /// Slow animation (for significant transitions)
  static const slow = Duration(milliseconds: 500);

  /// Very slow animation (for major scene changes)
  static const slower = Duration(milliseconds: 700);

  /// Extra slow animation (for dramatic effects)
  static const extraSlow = Duration(milliseconds: 1000);

  // ============================================================
  // CURVES
  // ============================================================

  /// Default easing curve - smooth deceleration
  static const curve = Curves.easeOutCubic;

  /// Standard Material curve
  static const curveStandard = Curves.easeInOut;

  /// Sharp, snappy curve for micro-interactions
  static const curveSharp = Curves.easeOutQuart;

  /// Bouncy curve for playful interactions
  static const curveBounce = Curves.elasticOut;

  /// Smooth curve with slight overshoot
  static const curveSmooth = Curves.easeOutBack;

  /// Linear curve (constant speed)
  static const curveLinear = Curves.linear;

  /// Decelerate curve (fast start, slow end)
  static const curveDecelerate = Curves.decelerate;

  // ============================================================
  // COMMON ANIMATION COMBINATIONS
  // ============================================================

  /// Fast transition with standard easing
  static const fastTransition = CurveTransition(
    curve: fast,
    easing: curve,
  );

  /// Medium transition with standard easing
  static const mediumTransition = CurveTransition(
    curve: medium,
    easing: curve,
  );

  /// Slow transition with smooth easing
  static const slowTransition = CurveTransition(
    curve: slow,
    easing: curveSmooth,
  );

  // ============================================================
  // SPECIFIC ANIMATION TYPES
  // ============================================================

  /// Fade in animation duration
  static const fadeIn = medium;

  /// Fade out animation duration
  static const fadeOut = fast;

  /// Slide animation duration
  static const slide = medium;

  /// Scale animation duration
  static const scale = fast;

  /// Rotation animation duration
  static const rotate = medium;

  /// Pulse animation duration (for repeating animations)
  static const pulse = Duration(milliseconds: 1500);

  /// Shimmer animation duration (for loading states)
  static const shimmer = Duration(milliseconds: 2000);

  // ============================================================
  // SPRING ANIMATIONS
  // ============================================================

  /// Default spring simulation for smooth physics-based animations
  static const spring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );

  /// Snappy spring (for quick, responsive interactions)
  static const springSnappy = SpringDescription(
    mass: 0.8,
    stiffness: 500.0,
    damping: 15.0,
  );

  /// Bouncy spring (for playful interactions)
  static const springBouncy = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 10.0,
  );

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Create a custom curve transition
  static CurveTransition customTransition({
    Duration duration = medium,
    Curve curve = Curves.easeOutCubic,
  }) {
    return CurveTransition(
      curve: duration,
      easing: curve,
    );
  }

  /// Get the appropriate curve for interaction type
  static Curve getCurveForType(AnimationType type) {
    switch (type) {
      case AnimationType.micro:
        return curveSharp;
      case AnimationType.standard:
        return curve;
      case AnimationType.smooth:
        return curveSmooth;
      case AnimationType.bouncy:
        return curveBounce;
    }
  }

  /// Get the appropriate duration for animation type
  static Duration getDurationForType(AnimationType type) {
    switch (type) {
      case AnimationType.micro:
        return fast;
      case AnimationType.standard:
        return medium;
      case AnimationType.smooth:
        return slow;
      case AnimationType.bouncy:
        return medium;
    }
  }
}

// ============================================================
// HELPER CLASSES
// ============================================================

/// Animation type enum for categorizing animations
enum AnimationType {
  /// Micro-interactions (hover, tap feedback)
  micro,

  /// Standard transitions (navigation, modal open)
  standard,

  /// Smooth, flowing animations (page transitions)
  smooth,

  /// Bouncy, playful animations (success states, celebrations)
  bouncy,
}

/// Simple curve transition data class
class CurveTransition {
  final Duration curve;
  final Curve easing;

  const CurveTransition({
    required this.curve,
    required this.easing,
  });
}

/// Common animation interval helpers for staggered animations
class AnimationInterval {
  /// Create interval as a fraction of total duration
  static Interval interval(double start, double end, {Curve curve = Curves.easeOut}) {
    return Interval(start, end, curve: curve);
  }

  /// Early interval (first third)
  static Interval early({Curve curve = Curves.easeOut}) {
    return interval(0.0, 0.33, curve: curve);
  }

  /// Middle interval (second third)
  static Interval middle({Curve curve = Curves.easeOut}) {
    return interval(0.33, 0.66, curve: curve);
  }

  /// Late interval (last third)
  static Interval late({Curve curve = Curves.easeOut}) {
    return interval(0.66, 1.0, curve: curve);
  }
}

// ============================================================
// PRE-BUILT ANIMATION WIDGETS
// ============================================================

/// Fade transition widget for consistent fade animations
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset? slideOffset;
  final bool enabled;

  const FadeIn({
    super.key,
    required this.child,
    this.duration = AppAnimations.medium,
    this.curve = AppAnimations.curve,
    this.slideOffset,
    this.enabled = true,
  });

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.slideOffset != null) {
      _slideAnimation = Tween<Offset>(
        begin: widget.slideOffset!,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
    }

    if (widget.enabled) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_slideAnimation != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation!,
          child: widget.child,
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

/// Scale transition widget for consistent scale animations
class ScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool enabled;
  final double beginScale;

  const ScaleIn({
    super.key,
    required this.child,
    this.duration = AppAnimations.fast,
    this.curve = AppAnimations.curve,
    this.enabled = true,
    this.beginScale = 0.8,
  });

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.enabled) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Staggered fade-in for list items
class StaggeredFadeIn extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;

  const StaggeredFadeIn({
    super.key,
    required this.child,
    required this.index,
    this.duration = AppAnimations.medium,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.curve = AppAnimations.curve,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: duration,
      curve: curve,
      enabled: true,
      child: child,
    );
  }
}
