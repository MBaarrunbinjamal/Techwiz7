import 'package:flutter/material.dart';
import './app_colors.dart';

class SourceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const SourceChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.primary : AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: selected ? Colors.white : AppColors.textDark),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
