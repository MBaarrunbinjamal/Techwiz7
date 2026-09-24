import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int percent;
  final Color color;
  final Color trackColor;

  const ProgressBar({
    super.key,
    required this.percent,
    required this.color,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: percent / 100,
        minHeight: 8,
        backgroundColor: trackColor,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}