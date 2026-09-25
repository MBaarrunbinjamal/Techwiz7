import 'package:flutter/material.dart';

/// Small rounded label used for tags, badges, and status chips.
class Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color color;
  final IconData? icon;

  const Pill({
    super.key,
    required this.text,
    required this.background,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, height: 1.1),
          ),
        ],
      ),
    );
  }
}
