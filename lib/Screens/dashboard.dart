import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:techwiz7/Services/FirebaseSupabaseService.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Dashboard();
  }
}

class _Dashboard extends State<Dashboard> {
  @override
  double totalincome = 0;
  double monthlyincome = 0;
  String firstname = '';
  String lastname = '';
  void initState() {
    // TODO: implement initState
    super.initState();
    getusername();
     getIncome();
  }
  Future<void> getIncome() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final uid = user.uid;

    final data = await FirebaseSupabaseService().read(
      tableName: 'income',
    );

    double overall = 0;
    double monthly = 0;

    final now = DateTime.now();

    if (data != null) {
      final incomes = Map<String, dynamic>.from(data);

      for (final item in incomes.values) {
        final income = Map<String, dynamic>.from(item);

        if (income['userid'].toString().trim() != uid.trim()) {
          continue;
        }

        final amount = double.tryParse(
          income['amount'].toString(),
        ) ??
            0;

        overall += amount;

        final date = DateTime.tryParse(
          income['date'].toString(),
        );

        if (date != null &&
            date.year == now.year &&
            date.month == now.month) {
          monthly += amount;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      totalincome = overall;
      monthlyincome = monthly;
    });
  }
  Future<void> getusername() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final uid = user.uid;

    final data = await FirebaseSupabaseService().read(
      tableName: 'users',
      id: uid,
    );

    if (data == null) return;

    if (!mounted) return;

    setState(() {
      firstname = data['FirstName']?.toString() ?? '';
      lastname = data['LastName']?.toString() ?? '';
    });
  }

  
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
              const SizedBox(height: 20),
              _greeting(),
              const SizedBox(height: 16),
              _balanceCard(),
              const SizedBox(height: 16),
              _summaryRow(),
              const SizedBox(height: 16),
              _quickActions(),
              const SizedBox(height: 16),
              _monthlyBudgetCard(),
              const SizedBox(height: 16),
              _savingsGoalCard(),
              const SizedBox(height: 16),
              _recentTransactions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PennyBottomNav(currentIndex: 0),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.greenSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.savings, color: AppColors.green, size: 22),
        ),
        const SizedBox(width: 10),
        const Text(
          'PennyPal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/notification'),
              child: const Icon(Icons.notifications_none, size: 26, color: AppColors.ink),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 9,
                height: 9,
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

  Widget _greeting() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$firstname $lastname',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Let's keep your budget thriving this week.",
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.amberSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco, size: 15, color: AppColors.amber),
              SizedBox(width: 5),
              Text(
                'Bee Level 4',
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

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.greenDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Total Available Income',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Income',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            '\$${totalincome.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'This month: \$${monthlyincome.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Total Income',
            amount: '\$${monthlyincome.toStringAsFixed(2)}',
            totalamount: '\$${totalincome.toStringAsFixed(2)}',
            note: 'On track this mo.',
            noteColor: AppColors.green,
            icon: Icons.arrow_upward,
            iconBg: AppColors.greenSoft,
            iconColor: AppColors.green,
            leadIcon: Icons.check_circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            title: 'Total Expenses',
            amount: '\$679.50',
            note: '68% of budget cap',
            noteColor: AppColors.amber,
            icon: Icons.arrow_downward,
            iconBg: AppColors.amberSoft,
            iconColor: AppColors.amber,
            leadIcon: Icons.info_outline, totalamount: '',
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String amount,
    required String note,
    required Color noteColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required IconData leadIcon, required String totalamount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: AppColors.muted),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 17, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(leadIcon, size: 14, color: noteColor),
              const SizedBox(width: 5),
              Text(
                note,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: noteColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _quickAction(Icons.add, 'Add\nIncome', AppColors.greenSoft, AppColors.green,route: '/addincome'),
          _quickAction(Icons.remove, 'Add\nExpense', AppColors.amberSoft, AppColors.amber, route: '/add-expense'),
          _quickAction(Icons.pie_chart_outline, 'Budgets', const Color(0xFFEDEBFB), const Color(0xFF6D5DD3), route: '/budget'),
          _quickAction(Icons.auto_awesome, 'AI Advice', const Color(0xFFE7EBFF), const Color(0xFF3B5BFF), route: '/ai'),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color bg, Color color, {String? route}) {
    return GestureDetector(
      onTap: route == null ? null : () => Navigator.pushNamed(context, route),
      child: Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
      ],
      ),
    );
  }

  Widget _monthlyBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.track_changes, color: AppColors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'May 2025 Spending Cap',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              _pill('32% safe zone', const Color(0xFFEAF0FB), const Color(0xFF3B5BFF)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '\$679.50',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              Spacer(),
              Text(
                'of \$1,000.00',
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _progressBar(0.68, AppColors.green),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '\$320.50 remaining',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
              ),
              const Spacer(),
              const Text(
                '11 days left',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _savingsGoalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.amberSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.laptop_mac, color: AppColors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laptop Fund',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Target: MacBook Air M3',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              _pill('3 months left', AppColors.amberSoft, AppColors.amber),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '\$650.00',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              Text(
                ' / \$1,000',
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
              Spacer(),
              Text(
                '65%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _progressBar(0.65, AppColors.amber),
        ],
      ),
    );
  }

  Widget _recentTransactions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/history'),
                child: Row(
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: AppColors.green),
                ],
              ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _transactionRow(
            icon: Icons.local_cafe,
            iconBg: const Color(0xFFEDEBFB),
            iconColor: const Color(0xFF6D5DD3),
            title: 'Campus Cafe',
            subtitle: 'Today, 10:45 AM  •  Food & Drink',
            amount: '-\$5.50',
            amountColor: AppColors.ink,
          ),
          const Divider(height: 24, color: AppColors.track),
          _transactionRow(
            icon: Icons.menu_book,
            iconBg: const Color(0xFFEDEBFB),
            iconColor: const Color(0xFF6D5DD3),
            title: 'Book Depository',
            subtitle: 'Yesterday, 3:20 PM  •  Education',
            amount: '-\$45.00',
            amountColor: AppColors.ink,
          ),
          const Divider(height: 24, color: AppColors.track),
          _transactionRow(
            icon: Icons.school,
            iconBg: AppColors.greenSoft,
            iconColor: AppColors.green,
            title: 'Tutoring Income',
            subtitle: 'May 18, 5:00 PM  •  Side Gig',
            amount: '+\$120.00',
            amountColor: AppColors.green,
          ),
        ],
      ),
    );
  }

  Widget _transactionRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.track),
    );
  }

  Widget _pill(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        ),
      ),
    );
  }

  Widget _progressBar(double value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 9,
        backgroundColor: AppColors.track,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}