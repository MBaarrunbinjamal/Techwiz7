import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';
import 'package:techwiz7/Models/TransactionModel.dart';
import 'package:techwiz7/Models/goal.dart';
import 'package:techwiz7/Services/BudgetService.dart';
import 'package:techwiz7/Services/FirebaseSupabaseService.dart';
import 'package:techwiz7/Services/goal_service.dart';
import 'package:techwiz7/Services/finance_calculator.dart';
import 'package:techwiz7/Services/PrefsService.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'budget_planner.dart';
import 'profile.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Dashboard();
  }
}

class _Dashboard extends State<Dashboard> {
  String firstname = '';

  double totalincome = 0;
  double monthlyincome = 0;
  double monthlyexpense = 0;
  double availableBalance = 0;

  String budgetCategory = '';
  double budgetLimit = 0;
  double budgetSpent = 0;

  Goal? featuredGoal;

  List<TransactionModel> recentTxns = [];

  @override
  void initState() {
    super.initState();
    getusername();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final uid = await PrefsService.instance.getUserId();

    if (uid == null || uid.isEmpty) {
      return;
    }

    try {
      final db = DatabaseHelper();

      final txns = await db.getTransactions(uid);
      final goals = await GoalService().getGoals();

      final month = FinanceCalculator.currentMonthKey();
      final progresses =
      await BudgetService().getBudgetsWithProgress(uid, month: month);

      BudgetProgress? feat;
      for (final p in progresses) {
        final id = p.budget.id ?? 0;
        final bestId = feat?.budget.id ?? -1;
        if (feat == null || id > bestId) {
          feat = p;
        }
      }

      final active = goals.where((g) => !g.isArchived).toList()
        ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
      Goal? goalFeat;
      if (active.isNotEmpty) {
        goalFeat = active.first;
      } else if (goals.isNotEmpty) {
        goalFeat = goals.first;
      }

      if (!mounted) return;

      setState(() {
        totalincome = FinanceCalculator.totalIncome(txns);
        monthlyincome = FinanceCalculator.monthlyIncome(txns);
        monthlyexpense = FinanceCalculator.monthlyExpense(txns);
        availableBalance = FinanceCalculator.availableBalance(txns, goals);
        budgetCategory = feat?.budget.category ?? '';
        budgetLimit = feat?.budget.limit ?? 0;
        budgetSpent = feat?.spent ?? 0;
        featuredGoal = goalFeat;
        recentTxns = FinanceCalculator.recent(txns, count: 3);
      });
    } catch (e, stackTrace) {
      print('DASHBOARD LOAD ERROR: $e');
      print(stackTrace);
    }
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
    });
  }

  void _openBudget() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BudgetPlanner()),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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

        GestureDetector(
          onTap: _openProfile,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 22,
              color: AppColors.green,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/notification'),
              child: const Icon(Icons.notifications_none,
                  size: 26, color: AppColors.ink),
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
                  border:
                  Border.all(color: AppColors.background, width: 1.5),
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
                '$firstname',
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
                'Available Balance',
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
                    Icon(Icons.trending_up, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Spendable',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '\$${availableBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This month income: \$${monthlyincome.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
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
            title: 'Income (This Month)',
            amount: '\$${monthlyincome.toStringAsFixed(2)}',
            totalamount: '\$${monthlyincome.toStringAsFixed(2)}',
            note: 'This month',
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
            title: 'Expenses (This Month)',
            amount: '\$${monthlyexpense.toStringAsFixed(2)}',
            totalamount: '\$${monthlyexpense.toStringAsFixed(2)}',
            note: 'This month',
            noteColor: AppColors.amber,
            icon: Icons.arrow_downward,
            iconBg: AppColors.amberSoft,
            iconColor: AppColors.amber,
            leadIcon: Icons.receipt_long,
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
    required IconData leadIcon,
    required String totalamount,
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
          _quickAction(Icons.add, 'Add\nIncome', AppColors.greenSoft,
              AppColors.green,
              route: '/addincome'),
          _quickAction(Icons.remove, 'Add\nExpense', AppColors.amberSoft,
              AppColors.amber,
              route: '/add-expense'),
          _quickAction(Icons.flag_outlined, 'Add\nGoals',
              const Color(0xFFEDEBFB), const Color(0xFF6D5DD3),
              route: '/savings'),
          _quickAction(Icons.pie_chart_outline, 'Set\nBudget',
              const Color(0xFFE7EBFF), const Color(0xFF3B5BFF),
              onTap: _openBudget),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color bg, Color color,
      {String? route, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ??
          (route == null ? null : () => Navigator.pushNamed(context, route)),
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
    if (budgetLimit <= 0) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.track_changes,
                  color: AppColors.green, size: 20),
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
                  SizedBox(height: 4),
                  Text(
                    'No budget set for this month',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _openBudget,
              child: _pill('Set', AppColors.greenSoft, AppColors.green),
            ),
          ],
        ),
      );
    }

    final pct = (budgetSpent / budgetLimit).clamp(0.0, 1.0);
    const over = Color(0xFFD64545);
    final barColor =
    pct < 0.8 ? AppColors.green : (pct < 1.0 ? AppColors.amber : over);
    final remaining = budgetLimit - budgetSpent;
    final daysLeft = FinanceCalculator.daysLeftInMonth();

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    final cat = budgetCategory.isEmpty ? '' : '$budgetCategory  •  ';
    final subLabel = '$cat${monthNames[now.month - 1]} ${now.year}';
    final titleLabel =
    budgetCategory.isEmpty ? 'Monthly Budget' : '$budgetCategory Budget';

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
                child: const Icon(Icons.track_changes,
                    color: AppColors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subLabel,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _openBudget,
                child: _pill('${(pct * 100).round()}% used',
                    const Color(0xFFEAF0FB), const Color(0xFF3B5BFF)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${budgetSpent.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                'of \$${budgetLimit.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _progressBar(pct, barColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration:
                BoxDecoration(color: barColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                remaining >= 0
                    ? '\$${remaining.toStringAsFixed(2)} remaining'
                    : 'Over by \$${(-remaining).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: remaining >= 0 ? AppColors.green : over,
                ),
              ),
              const Spacer(),
              Text(
                '$daysLeft days left',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _savingsGoalCard() {
    final g = featuredGoal;

    if (g == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.amberSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flag, color: AppColors.amber, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Savings Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No goal yet. Start saving for something.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/savings'),
              child: _pill('Create', AppColors.amberSoft, AppColors.amber),
            ),
          ],
        ),
      );
    }

    final pct = (g.percent / 100).clamp(0.0, 1.0);
    final pillText = g.hasEstimate
        ? '${g.monthsToComplete} mo to go'
        : '${g.monthsLeft} months left';

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
                child: const Icon(Icons.laptop_mac,
                    color: AppColors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      g.category.isNotEmpty ? g.category : 'Savings goal',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              _pill(pillText, AppColors.amberSoft, AppColors.amber),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${g.saved.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              Text(
                ' / \$${g.target.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
              ),
              const Spacer(),
              Text(
                '${g.percent.round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _progressBar(pct, AppColors.amber),
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
                    Icon(Icons.chevron_right,
                        size: 18, color: AppColors.green),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentTxns.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No transactions yet. Add your first income or expense.',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            )
          else
            ..._buildTransactionRows(),
        ],
      ),
    );
  }

  List<Widget> _buildTransactionRows() {
    final rows = <Widget>[];
    for (var i = 0; i < recentTxns.length; i++) {
      final t = recentTxns[i];
      final isIncome = t.type == 'income';
      rows.add(
        _transactionRow(
          icon: isIncome ? Icons.arrow_upward : Icons.arrow_downward,
          iconBg: isIncome ? AppColors.greenSoft : AppColors.amberSoft,
          iconColor: isIncome ? AppColors.green : AppColors.amber,
          title: t.description.isNotEmpty ? t.description : t.source,
          subtitle: '${_formatDate(t.date)}  •  ${t.source}',
          amount:
          '${isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
          amountColor: isIncome ? AppColors.green : AppColors.ink,
        ),
      );
      if (i < recentTxns.length - 1) {
        rows.add(const Divider(height: 24, color: AppColors.track));
      }
    }
    return rows;
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
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