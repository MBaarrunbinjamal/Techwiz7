import 'package:flutter/material.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'app_colors.dart';

// Budget Planner screen. Static design only.
class BudgetPlanner extends StatefulWidget {
  const BudgetPlanner({super.key});

  @override
  State<BudgetPlanner> createState() {
    return _BudgetPlanner();
  }
}


class _BudgetPlanner extends State<BudgetPlanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 18),
              _titleRow(),
              const SizedBox(height: 16),
              _monthlyTargetCard(),
              const SizedBox(height: 20),
              _breakdownHeader(),
              const SizedBox(height: 12),
              _entertainmentCard(),
              const SizedBox(height: 12),
              _categoryCard(
                icon: Icons.restaurant,
                iconBg: AppColors.amberSoft,
                iconColor: AppColors.amber,
                name: 'Food & Dining',
                percent: '84%',
                left: '\$40.00 left to spend',
                amount: '\$210.00',
                cap: 'of \$250.00',
                progress: 0.84,
                barColor: AppColors.amber,
              ),
              const SizedBox(height: 12),
              _categoryCard(
                icon: Icons.menu_book,
                iconBg: AppColors.amberSoft,
                iconColor: AppColors.amber,
                name: 'Education & Books',
                percent: '90%',
                left: '\$20.00 left to spend',
                amount: '\$180.00',
                cap: 'of \$200.00',
                progress: 0.90,
                barColor: AppColors.amber,
              ),
              const SizedBox(height: 12),
              _categoryCard(
                icon: Icons.directions_bus,
                iconBg: AppColors.greenSoft,
                iconColor: AppColors.green,
                name: 'Transport',
                percent: 'Healthy',
                left: '\$35.00 left',
                amount: '\$65.00',
                cap: 'of \$100.00',
                progress: 0.65,
                barColor: AppColors.green,
              ),
              const SizedBox(height: 12),
              _categoryCard(
                icon: Icons.shopping_bag_outlined,
                iconBg: AppColors.greenSoft,
                iconColor: AppColors.green,
                name: 'Shopping',
                percent: '56%',
                left: '\$65.50 left',
                amount: '\$84.50',
                cap: 'of \$150.00',
                progress: 0.56,
                barColor: AppColors.green,
              ),
              const SizedBox(height: 16),
              _bottomTiles(),
              const SizedBox(height: 18),
              _recalculateButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PennyBottomNav(currentIndex: 2),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        const Icon(Icons.savings, color: AppColors.green, size: 24),
        const SizedBox(width: 8),
        const Text(
          'PennyPal',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.track),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'October 2024',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.muted),
            ],
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, size: 24, color: AppColors.ink),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _titleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Budget Planner',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _pill('Bee Smart', AppColors.amberSoft, AppColors.amber),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Stay within limits and collect sweet savings',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.track),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 16, color: AppColors.ink),
              SizedBox(width: 6),
              Text(
                'Edit\nBudget',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _monthlyTargetCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF7F0), Color(0xFFFDF3E9)],
        ),
        border: Border.all(color: AppColors.track),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_outline, size: 20, color: AppColors.green),
              const SizedBox(width: 8),
              const Text(
                'MONTHLY\nTARGET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              _pill('On Track  •  7 days\nremaining', AppColors.greenSoft, AppColors.green),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Remaining',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '\$320.50',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _pill('68% spent', const Color(0xFFE4E1F5), AppColors.purple),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'of \$1,000.00 limit',
                            style: TextStyle(fontSize: 12, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _ring(0.68, '68%'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _legend(AppColors.green, 'Spent So Far', '\$679.50')),
              Expanded(child: _legend(AppColors.amber, 'Total Cap', '\$1,000.00')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color dot, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  // Circular ring showing percent used.
  Widget _ring(double value, String pct) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: 88,
            height: 88,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 9,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.track),
            ),
          ),
          SizedBox(
            width: 88,
            height: 88,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 9,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pct,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const Text(
                'USED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownHeader() {
    return Row(
      children: [
        const Text(
          'Categories Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(width: 8),
        _pill('5 Total', AppColors.blueSoft, AppColors.blue),
        const Spacer(),
        const Text(
          'View Insights',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.green,
          ),
        ),
      ],
    );
  }

  // The overspent Entertainment card, styled in red.
  Widget _entertainmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF6C9CE)),
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
                  color: const Color(0xFFF6C9CE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sports_esports, color: AppColors.red, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Entertainment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'Overspent',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Exceeded cap by \$20.00',
                      style: TextStyle(fontSize: 12, color: AppColors.red),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '\$140.00',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.red,
                    ),
                  ),
                  Text(
                    'Limit\n\$120.00',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bar(1.0, AppColors.red),
          const SizedBox(height: 10),
          Row(
            children: const [
              Text(
                '116% of allocated limit',
                style: TextStyle(fontSize: 12, color: AppColors.red),
              ),
              Spacer(),
              Text(
                'Rebalance',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // A normal category card.
  Widget _categoryCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String name,
    required String percent,
    required String left,
    required String amount,
    required String cap,
    required double progress,
    required Color barColor,
  }) {
    final bool healthy = percent == 'Healthy';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.track),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _pill(
                          percent,
                          healthy ? AppColors.greenSoft : AppColors.amberSoft,
                          healthy ? AppColors.green : AppColors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      left,
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    cap,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bar(progress, barColor),
        ],
      ),
    );
  }

  Widget _bottomTiles() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.muted.withValues(alpha: 0.4),                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: AppColors.green, size: 24),
                SizedBox(height: 4),
                Text(
                  '+ Add Category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'New monthly target',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.track),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.amberSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune, color: AppColors.amber, size: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Adjust Limits',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  'Fine-tune caps',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _recalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.calculate_outlined, size: 20),
        label: const Text(
          'Edit / Recalculate Budget',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _bar(double value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: AppColors.track,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
