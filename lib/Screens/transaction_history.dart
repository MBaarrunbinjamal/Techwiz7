import 'package:flutter/material.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'app_colors.dart';

// Transaction History screen. Static design only.
class TransactionHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TransactionHistory();
  }
}

class _TransactionHistory extends State<TransactionHistory> {
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
              _searchBar(),
              const SizedBox(height: 14),
              _tabs(),
              const SizedBox(height: 14),
              _filters(),
              const SizedBox(height: 16),
              _summaryCard(),
              const SizedBox(height: 18),
              _dateHeader('Today, Oct 24', '2 items  •  -\$51.25'),
              const SizedBox(height: 10),
              _txnRow(
                icon: Icons.school,
                iconBg: AppColors.purpleSoft,
                iconColor: AppColors.purple,
                title: 'Campus\nBookstore',
                pill: _pill('Tax\nDeductible', AppColors.blueSoft, AppColors.blue),
                sub: 'Education  •  3:42 PM',
                amount: '-\$45.00',
                amountColor: AppColors.ink,
                method: 'Checking\n*4920',
              ),
              const SizedBox(height: 10),
              _txnRow(
                icon: Icons.local_cafe,
                iconBg: AppColors.redSoft,
                iconColor: AppColors.red,
                title: 'Starbucks',
                sub: 'Food & Dining  •  9:15 AM',
                amount: '-\$6.25',
                amountColor: AppColors.ink,
                method: 'Apple Pay',
              ),
              const SizedBox(height: 18),
              _dateHeader('Yesterday, Oct 23', '2 items  •  +\$37.50'),
              const SizedBox(height: 10),
              _txnRow(
                icon: Icons.work_outline,
                iconBg: AppColors.greenSoft,
                iconColor: AppColors.green,
                title: 'Tutoring\nSession',
                pill: _pill('⚡ Side Gig', AppColors.greenSoft, AppColors.green),
                sub: 'Income  •  5:00 PM',
                subColor: AppColors.green,
                amount: '+\$60.00',
                amountColor: AppColors.green,
                method: 'Direct Deposit',
              ),
              const SizedBox(height: 10),
              _txnRow(
                icon: Icons.directions_subway,
                iconBg: AppColors.purpleSoft,
                iconColor: AppColors.purple,
                title: 'Subway Metro Pass',
                sub: 'Transport  •  8:30 AM',
                amount: '-\$22.50',
                amountColor: AppColors.ink,
                method: 'Transit Card',
              ),
              const SizedBox(height: 18),
              _dateHeader('Oct 20, 2024', '2 items  •  +\$484.01'),
              const SizedBox(height: 10),
              _txnRow(
                icon: Icons.payments_outlined,
                iconBg: AppColors.amberSoft,
                iconColor: AppColors.amber,
                title: 'Monthly\nAllowance',
                sub: 'Income  •  Family Wire',
                subColor: AppColors.green,
                amount: '+\$500.00',
                amountColor: AppColors.green,
                amountIcon: Icons.star,
                amountIconColor: AppColors.amber,
                method: 'Savings Hive',
              ),
              const SizedBox(height: 10),
              _txnRow(
                icon: Icons.movie_outlined,
                iconBg: AppColors.purpleSoft,
                iconColor: AppColors.purple,
                title: 'Netflix\nSubscription',
                pill: _pill('Recurring', AppColors.blueSoft, AppColors.blue),
                sub: 'Entertainment  •  Monthly',
                amount: '-\$15.99',
                amountColor: AppColors.ink,
                method: 'Checking\n*4920',
              ),
              const SizedBox(height: 20),
              _syncFooter(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PennyBottomNav(currentIndex: 1),
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
        const Icon(Icons.tune, size: 22, color: AppColors.ink),
        const SizedBox(width: 16),
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Track every penny, hive your wealth',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.amberSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.emoji_events, size: 15, color: AppColors.amber),
              SizedBox(width: 5),
              Text(
                'Level 4 Saver',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: const [
          Icon(Icons.search, size: 20, color: AppColors.muted),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search transactions, merchants, notes...',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ),
          Icon(Icons.mic_none, size: 20, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.purpleSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _tab('All', selected: true),
          _tab('Income'),
          _tab('Expense'),
        ],
      ),
    );
  }

  Widget _tab(String label, {bool selected = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return Row(
      children: [
        _filterChip('This Month'),
        const SizedBox(width: 10),
        _filterChip('Category: All'),
        const SizedBox(width: 10),
        _filterChip('Sort: Newest'),
      ],
    );
  }

  Widget _filterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.blue, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVITY SUMMARY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.muted,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '28 Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'NET FLOW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.muted,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '+\$1,420.50',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateHeader(String date, String items) {
    return Row(
      children: [
        Text(
          date,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        const Spacer(),
        Text(
          items,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _txnRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    Widget? pill,
    required String sub,
    Color subColor = AppColors.muted,
    required String amount,
    required Color amountColor,
    IconData? amountIcon,
    Color? amountIconColor,
    required String method,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (pill != null) ...[
                      const SizedBox(width: 8),
                      pill,
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: TextStyle(fontSize: 12, color: subColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (amountIcon != null) ...[
                    Icon(amountIcon, size: 15, color: amountIconColor),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                method,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.more_vert, size: 18, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _syncFooter() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified_outlined, size: 15, color: AppColors.muted),
          SizedBox(width: 6),
          Text(
            'All synced with linked student accounts',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.1,
        ),
      ),
    );
  }
}
