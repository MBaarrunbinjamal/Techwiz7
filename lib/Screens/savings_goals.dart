import 'package:flutter/material.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'package:techwiz7/shared/app_colors.dart';
import 'package:techwiz7/shared/goal_card.dart';
import 'package:techwiz7/shared/nav_item.dart';
import 'package:techwiz7/shared/pill_button.dart';
import 'package:techwiz7/shared/progress_bar.dart';

class SavingsGoals extends StatefulWidget {
  const SavingsGoals({super.key});

  @override
  State<SavingsGoals> createState() {
    return _SavingsGoalsState();
  }
}

class _SavingsGoalsState extends State<SavingsGoals> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.savings_outlined, color: AppColors.primary, size: 26),
        ),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PennyPal',
              style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text('Savings Goals', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.textDark),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryCard(),
            const SizedBox(height: 24),
            _activeGoalsHeader(),
            const SizedBox(height: 12),
            GoalCard(
              iconBg: const Color(0xFFEFF2F5),
              icon: Icons.laptop_mac_rounded,
              iconColor: AppColors.textDark,
              title: 'MacBook Air M3',
              subtitle: 'Tech & Work Setup',
              badgeIcon: Icons.access_time_rounded,
              badgeText: '2 mos left',
              badgeColor: AppColors.track,
              badgeTextColor: AppColors.textMuted,
              current: '\$650.00',
              total: '\$1,000.00',
              percent: 65,
              percentBg: const Color(0xFFDDF3E6),
              percentColor: AppColors.primaryDark,
              progressColor: AppColors.primary,
              leftIcon: Icons.savings_outlined,
              leftText: 'Contrib: \$150/mo',
              rightText: 'Target: Dec 2024',
              footerLeft: const Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'On track',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
              footerButton: const PillButton(label: 'Quick Deposit', icon: Icons.add, filled: true),
            ),
            const SizedBox(height: 14),
            GoalCard(
              iconBg: const Color(0xFFEFF2F5),
              icon: Icons.shield_outlined,
              iconColor: AppColors.textDark,
              title: 'Emergency Semester Buffer',
              subtitle: 'Safety & Living Fund',
              badgeIcon: Icons.check_circle,
              badgeText: 'Milestone Hit',
              badgeColor: const Color(0xFFDDF3E6),
              badgeTextColor: AppColors.primaryDark,
              current: '\$600.00',
              total: '\$800.00',
              percent: 75,
              percentBg: const Color(0xFFDDF3E6),
              percentColor: AppColors.primaryDark,
              progressColor: AppColors.primary,
              leftIcon: Icons.calendar_today_rounded,
              leftText: 'Contrib: \$100/mo',
              rightText: 'Target: Jan 2025',
              footerLeft: const Text(
                'Auto-transfers every 1st of month',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
              footerButton: const PillButton(label: 'Edit', icon: Icons.tune_rounded, filled: false),
            ),
            const SizedBox(height: 14),
            GoalCard(
              iconBg: const Color(0xFFFBEAD9),
              icon: Icons.directions_car_filled_rounded,
              iconColor: const Color(0xFFB8672A),
              title: 'Spring Break Roadtrip',
              subtitle: 'Travel & Leisure',
              badgeIcon: Icons.wb_sunny_rounded,
              badgeText: 'Mar 2025',
              badgeColor: AppColors.track,
              badgeTextColor: AppColors.textMuted,
              current: '\$230.00',
              total: '\$500.00',
              percent: 46,
              percentBg: AppColors.amberBg,
              percentColor: const Color(0xFF9A5B10),
              progressColor: AppColors.amber,
              leftIcon: Icons.show_chart_rounded,
              leftText: 'Contrib: \$75/mo',
              rightText: 'Needs: \$270.00',
              footerLeft: const Text(
                '3 months left',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
              footerButton: const PillButton(label: 'Deposit', icon: Icons.add, filled: false),
            ),
            const SizedBox(height: 16),
            _completedGoalsBanner(),
            const SizedBox(height: 20),
            _createGoalButton(),
          ],
        ),
      ),
      bottomNavigationBar: PennyBottomNav(currentIndex: 0),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9F7F0), Color(0xFFFDF1E4)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.amberBg, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.military_tech_rounded, size: 14, color: Color(0xFF9A5B10)),
                    SizedBox(width: 4),
                    Text(
                      'LEVEL 3 SAVER',
                      style: TextStyle(
                        color: Color(0xFF9A5B10),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.trending_up_rounded, size: 16, color: AppColors.primaryDark),
                  SizedBox(width: 2),
                  Text(
                    '+14% this month',
                    style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 12.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Total Saved Across 3 Goals', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '\$1,480',
                  style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 32),
                ),
                TextSpan(
                  text: '.00',
                  style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 20),
                ),
                TextSpan(text: '  / \$2,300.00', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress (64%)',
                style: TextStyle(color: AppColors.textDark, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              Text('\$820.00 left to milestone', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 8),
          const ProgressBar(percent: 64, color: AppColors.primary, trackColor: Colors.white),
        ],
      ),
    );
  }

  Widget _activeGoalsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Active Goals',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(20)),
          child: const Text(
            '3 Active',
            style: TextStyle(color: AppColors.lavenderText, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _completedGoalsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View 2 Completed Goals',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
                ),
                SizedBox(height: 2),
                Text(
                  'Concert Pass & Emergency Clinic (\$1,200 achieved)',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _createGoalButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create New Goal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}