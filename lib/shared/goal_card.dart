import 'package:flutter/material.dart';
import 'package:techwiz7/shared/app_colors.dart';
import 'progress_bar.dart';

class GoalCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final IconData badgeIcon;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final String current;
  final String total;
  final int percent;
  final Color percentBg;
  final Color percentColor;
  final Color progressColor;
  final IconData leftIcon;
  final String leftText;
  final String rightText;
  final Widget footerLeft;
  final Widget footerButton;
  final bool showMilestones;

  const GoalCard({
    super.key,
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badgeIcon,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.current,
    required this.total,
    required this.percent,
    required this.percentBg,
    required this.percentColor,
    required this.progressColor,
    required this.leftIcon,
    required this.leftText,
    required this.rightText,
    required this.footerLeft,
    required this.footerButton,
    this.showMilestones = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 13, color: badgeTextColor),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: badgeTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: current,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: ' / $total',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: percentBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    color: percentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(
            percent: percent,
            color: progressColor,
            trackColor: AppColors.track,
          ),
          if (showMilestones) ...[
            const SizedBox(height: 12),
            _milestoneRow(),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(leftIcon, size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 5),
                  Text(
                    leftText,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              Text(
                rightText,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.cardBorder),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: footerLeft),
              const SizedBox(width: 8),
              footerButton,
            ],
          ),
        ],
      ),
    );
  }

  // FR-37 milestone badges. Four marks at 25, 50, 75, and 100 percent.
  // A mark fills in once progress passes it.
  Widget _milestoneRow() {
    const marks = [25, 50, 75, 100];
    return Row(
      children: marks.map((m) {
        final reached = percent >= m;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: reached ? const Color(0xFFDDF3E6) : AppColors.track,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  reached ? Icons.emoji_events : Icons.lock_outline,
                  size: 12,
                  color: reached ? AppColors.primaryDark : AppColors.textMuted,
                ),
                const SizedBox(width: 3),
                Text(
                  '$m%',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: reached ? AppColors.primaryDark : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}