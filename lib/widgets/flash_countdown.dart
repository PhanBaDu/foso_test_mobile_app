import 'package:flutter/material.dart';

import '../theme.dart';
import 'rolling_number.dart';

export 'rolling_number.dart';

class FlashCountdown extends StatelessWidget {
  const FlashCountdown({super.key, required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < values.length; i++) ...[
        if (i > 0)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ),
        _CountdownTile(key: ValueKey('countdown-unit-$i'), value: values[i]),
      ],
    ],
  );
}

class _CountdownTile extends StatelessWidget {
  const _CountdownTile({super.key, required this.value});
  final String value;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Container(
      width: 26,
      height: 26,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE6FFFFFF), Color(0x1FFFFFFF)],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(3.5),
        ),
        child: Center(
          child: Semantics(
            label: value,
            excludeSemantics: true,
            child: RollingNumber(
              value: value,
              fontSize: 13,
              digitWidth: 8,
              digitHeight: 18,
            ),
          ),
        ),
      ),
    ),
  );
}
