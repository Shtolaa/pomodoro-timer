import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../features/app_theme/domain/pomodoro_theme.dart';

class DreamyBackdrop extends StatelessWidget {
  const DreamyBackdrop({super.key, required this.theme});

  final PomodoroThemeOption theme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 72,
          right: 36,
          child:
              _GlowOrb(size: 98, color: theme.accent.withValues(alpha: 0.54)),
        ),
        Positioned(
          top: 138,
          left: -34,
          child: _GlowOrb(
              size: 160, color: theme.softAccent.withValues(alpha: 0.36)),
        ),
        Positioned(
          bottom: 88,
          right: -42,
          child: _GlowOrb(
              size: 190, color: theme.secondary.withValues(alpha: 0.35)),
        ),
        _Star(top: 98, left: 60, size: 5, theme: theme),
        _Star(top: 182, right: 84, size: 4, theme: theme),
        _Star(bottom: 182, left: 44, size: 6, theme: theme),
        _Star(bottom: 60, right: 126, size: 4, theme: theme),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 42, spreadRadius: 14)],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star(
      {this.top,
      this.right,
      this.bottom,
      this.left,
      required this.size,
      required this.theme});

  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double size;
  final PomodoroThemeOption theme;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.card.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(1.4),
            boxShadow: [
              BoxShadow(
                color: theme.card.withValues(alpha: 0.55),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
