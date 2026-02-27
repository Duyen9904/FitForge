import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Trophy icon with "Congratulations!" title and subtitle.
/// Also renders decorative star particles around the trophy.
class CongratulationsTrophy extends StatelessWidget {
  const CongratulationsTrophy({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trophy with decorative particles
        SizedBox(
          width: 200,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative stars / sparkles
              ..._buildParticles(),

              // Trophy icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warning.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.spacing16),

        // "Congratulations!" text
        Text(
          'Congratulations!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                fontSize: 28,
              ),
        ),

        const SizedBox(height: AppDimensions.spacing8),

        // Subtitle
        Text(
          'You have completed the workout!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withOpacity(0.8),
                fontSize: 15,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildParticles() {
    const particleData = <Map<String, dynamic>>[
      {'top': 10.0, 'left': 30.0, 'size': 14.0, 'color': Color(0xFFFFD700)},
      {'top': 5.0, 'right': 40.0, 'size': 10.0, 'color': Color(0xFFFF7EB6)},
      {'top': 40.0, 'left': 10.0, 'size': 8.0, 'color': Color(0xFF7C5CFF)},
      {'top': 25.0, 'right': 15.0, 'size': 12.0, 'color': Color(0xFFFFD700)},
      {'bottom': 30.0, 'left': 25.0, 'size': 10.0, 'color': Color(0xFFFF7EB6)},
      {'bottom': 20.0, 'right': 30.0, 'size': 8.0, 'color': Color(0xFF7C5CFF)},
      {'top': 70.0, 'left': 5.0, 'size': 6.0, 'color': Color(0xFFFFD700)},
      {'top': 60.0, 'right': 8.0, 'size': 9.0, 'color': Color(0xFFFF7EB6)},
    ];

    return particleData.map((data) {
      return Positioned(
        top: data['top'] as double?,
        left: data['left'] as double?,
        right: data['right'] as double?,
        bottom: data['bottom'] as double?,
        child: Icon(
          Icons.star_rounded,
          size: data['size'] as double,
          color: data['color'] as Color,
        ),
      );
    }).toList();
  }
}
