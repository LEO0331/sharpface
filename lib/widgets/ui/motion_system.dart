import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';

enum MotionPreset { relaxed, balanced, snappy }

class AppMotion {
  AppMotion._();

  static final ValueNotifier<MotionPreset> profileNotifier = ValueNotifier(
    MotionPreset.balanced,
  );

  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve fadeCurve = Curves.easeOut;

  static MotionPreset get profile => profileNotifier.value;

  static String get profileLabel => switch (profile) {
    MotionPreset.relaxed => 'relaxed',
    MotionPreset.balanced => 'balanced',
    MotionPreset.snappy => 'snappy',
  };

  static Duration get pageEnter => switch (profile) {
    MotionPreset.relaxed => const Duration(milliseconds: 520),
    MotionPreset.balanced => AppTokens.motionMedium,
    MotionPreset.snappy => const Duration(milliseconds: 220),
  };

  static Duration get staggerStep => switch (profile) {
    MotionPreset.relaxed => const Duration(milliseconds: 120),
    MotionPreset.balanced => const Duration(milliseconds: 90),
    MotionPreset.snappy => const Duration(milliseconds: 64),
  };

  static Duration get hover => switch (profile) {
    MotionPreset.relaxed => const Duration(milliseconds: 250),
    MotionPreset.balanced => AppTokens.motionFast,
    MotionPreset.snappy => const Duration(milliseconds: 120),
  };

  static Duration get indicator => switch (profile) {
    MotionPreset.relaxed => const Duration(milliseconds: 320),
    MotionPreset.balanced => const Duration(milliseconds: 260),
    MotionPreset.snappy => const Duration(milliseconds: 180),
  };

  static MotionPreset cyclePreset() {
    final next = switch (profile) {
      MotionPreset.relaxed => MotionPreset.balanced,
      MotionPreset.balanced => MotionPreset.snappy,
      MotionPreset.snappy => MotionPreset.relaxed,
    };
    profileNotifier.value = next;
    return next;
  }
}

class MotionPresetBuilder extends StatelessWidget {
  const MotionPresetBuilder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MotionPreset>(
      valueListenable: AppMotion.profileNotifier,
      builder: (context, value, childWidget) => child,
    );
  }
}

class MotionPresetSwitcherButton extends StatelessWidget {
  const MotionPresetSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MotionPreset>(
      valueListenable: AppMotion.profileNotifier,
      builder: (context, value, childWidget) {
        return IconButton(
          tooltip: '動效節奏：${AppMotion.profileLabel}',
          icon: const Icon(Icons.speed_outlined),
          onPressed: () {
            final next = AppMotion.cyclePreset();
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
              SnackBar(
                content: Text(
                  '動效節奏切換為 ${switch (next) {
                    MotionPreset.relaxed => 'relaxed',
                    MotionPreset.balanced => 'balanced',
                    MotionPreset.snappy => 'snappy',
                  }}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PageEnterTransition extends StatefulWidget {
  const PageEnterTransition({super.key, required this.child});

  final Widget child;

  @override
  State<PageEnterTransition> createState() => _PageEnterTransitionState();
}

class _PageEnterTransitionState extends State<PageEnterTransition> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MotionReveal(
      visible: _visible,
      offset: const Offset(0, 0.035),
      child: widget.child,
    );
  }
}

class MotionReveal extends StatelessWidget {
  const MotionReveal({
    super.key,
    required this.visible,
    required this.child,
    this.offset = const Offset(0, 0.05),
  });

  final bool visible;
  final Widget child;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: AppMotion.pageEnter,
      curve: AppMotion.fadeCurve,
      child: AnimatedSlide(
        duration: AppMotion.pageEnter,
        curve: AppMotion.enterCurve,
        offset: visible ? Offset.zero : offset,
        child: child,
      ),
    );
  }
}

class StaggerReveal extends StatefulWidget {
  const StaggerReveal({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<StaggerReveal> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppMotion.staggerStep * widget.index, () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MotionReveal(
      visible: _visible,
      offset: const Offset(0, 0.04),
      child: widget.child,
    );
  }
}
