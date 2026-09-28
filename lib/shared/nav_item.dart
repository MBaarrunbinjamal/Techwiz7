import 'package:flutter/material.dart';
import 'package:techwiz7/shared/app_colors.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = active ? AppColors.primary : AppColors.textMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: active ? 1.0 : 0.55,
          child: Image.asset(
            'assets/logo.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(icon, color: color, size: 24);
            },
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (active) ...[
          const SizedBox(height: 2),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}