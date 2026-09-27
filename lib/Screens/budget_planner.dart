import 'package:flutter/material.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';
import 'package:techwiz7/Services/BudgetService.dart';
import 'app_colors.dart';

class BudgetPlanner extends StatefulWidget {
  const BudgetPlanner({super.key});

  @override
  State<BudgetPlanner> createState() => _BudgetPlanner();
}

class _BudgetPlanner extends State<BudgetPlanner> {
  final _budgetService = BudgetService();
  final _dbHelper = DatabaseHelper.instance;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food',
      'icon': Icons.lunch_dining,
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_bus,
    },
    {
      'name': 'Education',
      'icon': Icons.school,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'name': 'Fun',
      'icon': Icons.movie_outlined,
    },
    {
      'name': 'Bills',
      'icon': Icons.receipt_long,
    },
    {
      'name': 'Savings',
      'icon': Icons.savings,
    },
    {
      'name': 'Misc',
      'icon': Icons.more_horiz,
    },
  ];

  DateTime _selectedMonth =
  DateTime(DateTime.now().year, DateTime.now().month);

  String? _userId;
  bool _loading = true;
  List<BudgetProgress> _budgets = [];

  String get _monthKey =>
      '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

  String get _monthLabel =>
      '${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}';

  double get _totalLimit =>
      _budgets.fold(0.0, (sum, budget) => sum + budget.budget.limit);

  double get _totalSpent =>
      _budgets.fold(0.0, (sum, budget) => sum + budget.spent);

  double get _totalRemaining => _totalLimit - _totalSpent;

  double get _totalPercent =>
      _totalLimit <= 0 ? 0 : (_totalSpent / _totalLimit).clamp(0, 1);

  bool get _isCurrentMonth {
    final now = DateTime.now();

    return now.year == _selectedMonth.year &&
        now.month == _selectedMonth.month;
  }

  int get _daysRemainingInMonth {
    final lastDay =
    DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    if (!_isCurrentMonth) {
      return lastDay.day;
    }

    return lastDay.day - DateTime.now().day;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final user = await _dbHelper.getuserid();

      _userId = user?.userId;

      if (_userId != null) {
        await _budgetService.refreshAllStatuses(_userId!);

        _budgets = await _budgetService.getBudgetsWithProgress(
          _userId!,
          month: _monthKey,
        );
      } else {
        _budgets = [];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load budgets. Please try again.'),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _changeMonth(int deltaMonths) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + deltaMonths,
      );
    });

    _load();
  }

  Future<void> _openAddBudgetSheet() async {
    String? selectedCategory;
    final limitController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Budget',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'For $_monthLabel',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['name'] as String,
                          child: Row(
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(category['name'] as String),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: limitController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Monthly limit',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');

                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          if (_userId == null) {
                            // FIX: Use parent 'context' here, not 'ctx'
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'User account could not be found.',
                                ),
                              ),
                            );
                            return;
                          }

                          final alreadyExists = _budgets.any(
                                (budget) =>
                            budget.budget.category.toLowerCase() ==
                                selectedCategory!.toLowerCase(),
                          );

                          if (alreadyExists) {
                            // FIX: Use parent 'context' here, not 'ctx'
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'A budget for this category already exists.',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            await _budgetService.createBudget(
                              userId: _userId!,
                              category: selectedCategory!,
                              limit: double.parse(
                                limitController.text.trim(),
                              ),
                              month: _monthKey,
                            );

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }

                            if (mounted) {
                              // FIX: Use parent 'context' here, not 'ctx'
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Budget added successfully.',
                                  ),
                                ),
                              );
                            }

                            await _load();
                          } catch (e) {
                            if (ctx.mounted) {
                              // FIX: Use parent 'context' here, not 'ctx'
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Unable to save budget. Please try again.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Save Budget',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    limitController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24,
            ),
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

                if (_budgets.isEmpty)
                  _emptyState()
                else
                  for (final bp in _budgets) ...[
                    _categoryCardFromProgress(bp),
                    const SizedBox(height: 12),
                  ],

                const SizedBox(height: 8),

                _addBudgetButton(),

                const SizedBox(height: 18),

                _recalculateButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const PennyBottomNav(
        currentIndex: 2,
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.track,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.pie_chart_outline,
            size: 32,
            color: AppColors.muted,
          ),
          const SizedBox(height: 8),
          Text(
            'No budgets set for $_monthLabel yet.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _openAddBudgetSheet,
            icon: const Icon(
              Icons.add,
              color: AppColors.green,
            ),
            label: const Text(
              'Add Budget',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        const Icon(
          Icons.savings,
          color: AppColors.green,
          size: 24,
        ),
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

        PopupMenuButton<int>(
          onSelected: _changeMonth,
          itemBuilder: (ctx) => const [
            PopupMenuItem(
              value: -1,
              child: Text('◀ Previous month'),
            ),
            PopupMenuItem(
              value: 1,
              child: Text('Next month ▶'),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.track,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _monthLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 24,
              color: AppColors.ink,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 1.5,
                  ),
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
                  _pill(
                    'Bee Smart',
                    AppColors.amberSoft,
                    AppColors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Stay within limits and collect sweet savings',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _monthlyTargetCard() {
    final statusLabel = _isCurrentMonth
        ? 'On Track  •  $_daysRemainingInMonth days\nremaining'
        : 'Past month';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF7F0),
            Color(0xFFFDF3E9),
          ],
        ),
        border: Border.all(
          color: AppColors.track,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline,
                size: 20,
                color: AppColors.green,
              ),
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
              _pill(
                statusLabel,
                AppColors.greenSoft,
                AppColors.green,
              ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${_totalRemaining.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _pill(
                          '${(_totalPercent * 100).round()}% spent',
                          const Color(0xFFE4E1F5),
                          AppColors.purple,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'of \$${_totalLimit.toStringAsFixed(2)} limit',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _ring(
                _totalPercent,
                '${(_totalPercent * 100).round()}%',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _legend(
                  AppColors.green,
                  'Spent So Far',
                  '\$${_totalSpent.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _legend(
                  AppColors.amber,
                  'Total Cap',
                  '\$${_totalLimit.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(
      Color dot,
      String label,
      String value,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
              ),
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

  Widget _ring(
      double value,
      String pct,
      ) {
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
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.track,
              ),
            ),
          ),
          SizedBox(
            width: 88,
            height: 88,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 9,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.green,
              ),
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
        _pill(
          '${_budgets.length} Total',
          AppColors.blueSoft,
          AppColors.blue,
        ),
      ],
    );
  }

  Widget _categoryCardFromProgress(
      BudgetProgress bp,
      ) {
    if (bp.isExceeded) {
      return _overspentCard(bp);
    }

    final warning = bp.percentUsed >= 0.8;

    return _categoryCard(
      icon: _iconFor(bp.budget.category),
      iconBg: warning
          ? AppColors.amberSoft
          : AppColors.greenSoft,
      iconColor: warning
          ? AppColors.amber
          : AppColors.green,
      name: bp.budget.category,
      percent: warning
          ? '${(bp.percentUsed * 100).round()}%'
          : 'Healthy',
      left: '\$${bp.remaining.toStringAsFixed(2)} left to spend',
      amount: '\$${bp.spent.toStringAsFixed(2)}',
      cap: 'of \$${bp.budget.limit.toStringAsFixed(2)}',
      progress: bp.percentUsed,
      barColor: warning
          ? AppColors.amber
          : AppColors.green,
    );
  }

  IconData _iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.lunch_dining;

      case 'transport':
        return Icons.directions_bus;

      case 'education':
        return Icons.school;

      case 'shopping':
        return Icons.shopping_bag_outlined;

      case 'fun':
        return Icons.movie_outlined;

      case 'bills':
        return Icons.receipt_long;

      case 'savings':
        return Icons.savings;

      case 'misc':
        return Icons.more_horiz;

      default:
        return Icons.category_outlined;
    }
  }

  Widget _overspentCard(
      BudgetProgress bp,
      ) {
    final overBy = bp.spent - bp.budget.limit;

    final percentOfLimit = bp.budget.limit <= 0
        ? 0
        : ((bp.spent / bp.budget.limit) * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF6C9CE),
        ),
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
                child: Icon(
                  _iconFor(bp.budget.category),
                  color: AppColors.red,
                  size: 22,
                ),
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
                            bp.budget.category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
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
                    Text(
                      'Exceeded cap by \$${overBy.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${bp.spent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.red,
                    ),
                  ),
                  Text(
                    'Limit\n\$${bp.budget.limit.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bar(
            1.0,
            AppColors.red,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '$percentOfLimit% of allocated limit',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        border: Border.all(
          color: AppColors.track,
        ),
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
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
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
                          healthy
                              ? AppColors.greenSoft
                              : AppColors.amberSoft,
                          healthy
                              ? AppColors.green
                              : AppColors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      left,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
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
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bar(
            progress,
            barColor,
          ),
        ],
      ),
    );
  }

  Widget _addBudgetButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _openAddBudgetSheet,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          side: const BorderSide(
            color: AppColors.green,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        icon: const Icon(
          Icons.add,
          size: 20,
        ),
        label: const Text(
          'Add Budget',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _recalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _load,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        icon: const Icon(
          Icons.calculate_outlined,
          size: 20,
        ),
        label: const Text(
          'Recalculate Budget',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _pill(
      String text,
      Color bg,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
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

  Widget _bar(
      double value,
      Color color,
      ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 8,
        backgroundColor: AppColors.track,
        valueColor: AlwaysStoppedAnimation<Color>(
          color,
        ),
      ),
    );
  }
}