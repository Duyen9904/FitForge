import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Animated trophy icon with rotating/fading sparkle particles
/// and a scale bounce-in animation on mount.
class CongratulationsTrophy extends StatefulWidget {
  const CongratulationsTrophy({super.key});

  @override
  State<CongratulationsTrophy> createState() => _CongratulationsTrophyState();
}

class _CongratulationsTrophyState extends State<CongratulationsTrophy>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _particleController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Bounce-in for trophy
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
    _bounceController.forward();

    // Continuous rotation for particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated rotating particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _particleController.value * 2 * pi,
                child: child,
              );
            },
            child: SizedBox(
              width: 220,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: _buildParticles(),
              ),
            ),
          ),

          // Trophy with bounce-in
          ScaleTransition(
            scale: _bounceAnimation,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.warning.withValues(alpha: 0.25),
                    AppColors.warning.withValues(alpha: 0.08),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 64,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    const particleData = <Map<String, dynamic>>[
      {'top': 10.0, 'left': 30.0, 'size': 16.0, 'color': Color(0xFFFFD700)},
      {'top': 0.0, 'right': 40.0, 'size': 12.0, 'color': Color(0xFFFF7EB6)},
      {'top': 45.0, 'left': 5.0, 'size': 10.0, 'color': Color(0xFF7C5CFF)},
      {'top': 20.0, 'right': 10.0, 'size': 14.0, 'color': Color(0xFFFFD700)},
      {'bottom': 35.0, 'left': 20.0, 'size': 12.0, 'color': Color(0xFFFF7EB6)},
      {'bottom': 15.0, 'right': 25.0, 'size': 10.0, 'color': Color(0xFF7C5CFF)},
      {'top': 75.0, 'left': 0.0, 'size': 8.0, 'color': Color(0xFFFFD700)},
      {'top': 60.0, 'right': 5.0, 'size': 11.0, 'color': Color(0xFFFF7EB6)},
      {'bottom': 55.0, 'left': 40.0, 'size': 7.0, 'color': Color(0xFF22C55E)},
      {'top': 85.0, 'right': 35.0, 'size': 9.0, 'color': Color(0xFF3B82F6)},
    ];

    return particleData.map((data) {
      return Positioned(
        top: data['top'] as double?,
        left: data['left'] as double?,
        right: data['right'] as double?,
        bottom: data['bottom'] as double?,
        child: _AnimatedParticle(
          size: data['size'] as double,
          color: data['color'] as Color,
          controller: _particleController,
        ),
      );
    }).toList();
  }
}

class _AnimatedParticle extends StatelessWidget {
  final double size;
  final Color color;
  final AnimationController controller;

  const _AnimatedParticle({
    required this.size,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Pulsing opacity
        final opacity = 0.4 + 0.6 * sin(controller.value * 2 * pi).abs();
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Icon(
        Icons.star_rounded,
        size: size,
        color: color,
      ),
    );
  }
}
