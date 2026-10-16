import 'package:flutter/material.dart';
import '../theme.dart';

class SalesProgress extends StatelessWidget {
  const SalesProgress({super.key, this.value = 0.63});
  final double value;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 22,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final progress = value.clamp(0.0, 1.0);
          final badgeX = (constraints.maxWidth * progress - 11).clamp(
            0.0,
            (constraints.maxWidth - 22).clamp(0.0, double.infinity),
          );
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.salesProgressTrack,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.salesProgressStart,
                        AppColors.salesProgressEnd,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: badgeX,
                child: const FigmaIcon('flashsale', size: 22),
              ),
            ],
          );
        },
      ),
    ),
  );
}
