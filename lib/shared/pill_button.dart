import 'package:flutter/material.dart';
import 'package:techwiz7/shared/app_colors.dart';

class PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;

  const PillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(
        icon,
        size: 16,
        color: filled ? Colors.white : AppColors.lavenderText,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: filled ? Colors.white : AppColors.lavenderText,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? AppColors.primary : AppColors.lavender,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}