import 'package:flutter/material.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'package:techwiz7/shared/app_colors.dart';
import 'package:techwiz7/shared/goal_card.dart';
import 'package:techwiz7/shared/pill_button.dart';
import 'package:techwiz7/shared/progress_bar.dart';
import 'package:techwiz7/Models/goal.dart';
import 'package:techwiz7/Services/goal_service.dart';

class SavingsGoals extends StatefulWidget {
  const SavingsGoals({super.key});

  @override
  State<SavingsGoals> createState() {
    return _SavingsGoalsState();
  }
}

class _SavingsGoalsState extends State<SavingsGoals> {
  final _service = GoalService();
  List<Goal> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final goals = await _service.getGoals();
      if (!mounted) return;
      setState(() {
        _goals = goals;
        _loading = false;
      });
      await _service.syncPending();
    } catch (e) {
      print('[GOAL LOAD ERROR] $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Goal> get _active => _goals.where((g) => !g.isComplete).toList();
  List<Goal> get _completed => _goals.where((g) => g.isComplete).toList();
  double get _totalSaved => _goals.fold(0.0, (s, g) => s + g.saved);
  double get _totalTarget => _goals.fold(0.0, (s, g) => s + g.target);
  int get _overallPercent =>
      _totalTarget == 0 ? 0 : (_totalSaved / _totalTarget * 100).round();

  Future<void> _openCreateDialog() async {
    final created = await showDialog<Goal>(
      context: context,
      builder: (_) => const _CreateGoalDialog(),
    );
    if (created != null) {
      await _service.add(created);
      await _load();
    }
  }

  Future<void> _openDepositDialog(Goal g) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => _DepositDialog(goalTitle: g.title),
    );
    if (amount != null && amount > 0) {
      await _service.deposit(g.id, amount, g.saved);
      await _load();
    }
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'Tech & Work Setup':
        return Icons.laptop_mac_rounded;
      case 'Travel & Leisure':
        return Icons.directions_car_filled_rounded;
      case 'Safety & Living Fund':
        return Icons.shield_outlined;
      default:
        return Icons.flag_rounded;
    }
  }

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
            onPressed: _openCreateDialog,
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
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_active.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'No goals yet. Create your first goal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              )
            else
              ..._active.map(_buildGoalCard),
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

  Widget _buildGoalCard(Goal g) {
    final ahead = g.percent >= 60;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GoalCard(
        iconBg: const Color(0xFFEFF2F5),
        icon: _iconFor(g.category),
        iconColor: AppColors.textDark,
        title: g.title,
        subtitle: g.category,
        badgeIcon: Icons.access_time_rounded,
        badgeText: '${g.monthsLeft} mos left',
        badgeColor: AppColors.track,
        badgeTextColor: AppColors.textMuted,
        current: '\$${g.saved.toStringAsFixed(2)}',
        total: '\$${g.target.toStringAsFixed(2)}',
        percent: g.percent.round(),
        percentBg: ahead ? const Color(0xFFDDF3E6) : AppColors.amberBg,
        percentColor: ahead ? AppColors.primaryDark : const Color(0xFF9A5B10),
        progressColor: ahead ? AppColors.primary : AppColors.amber,
        leftIcon: Icons.savings_outlined,
        leftText: 'Contrib: \$${g.monthly.toStringAsFixed(0)}/mo',
        rightText: 'Needs: \$${g.remaining.toStringAsFixed(2)}',
        footerLeft: Text(
          ahead ? 'On track' : '${g.monthsLeft} months left',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
        ),
        footerButton: GestureDetector(
          onTap: () => _openDepositDialog(g),
          child: const PillButton(label: 'Deposit', icon: Icons.add, filled: true),
        ),
      ),
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
          Text(
            'Total Saved Across ${_goals.length} Goals',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\$${_totalSaved.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 32),
                ),
                TextSpan(
                  text: '  / \$${_totalTarget.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress ($_overallPercent%)',
                style: const TextStyle(
                    color: AppColors.textDark, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              Text(
                '\$${(_totalTarget - _totalSaved).clamp(0, double.infinity).toStringAsFixed(2)} left',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(percent: _overallPercent, color: AppColors.primary, trackColor: Colors.white),
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
          child: Text(
            '${_active.length} Active',
            style: const TextStyle(color: AppColors.lavenderText, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _completedGoalsBanner() {
    if (_completed.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View ${_completed.length} Completed Goals',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  _completed.map((g) => g.title).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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
        onPressed: _openCreateDialog,
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

class _CreateGoalDialog extends StatefulWidget {
  const _CreateGoalDialog();

  @override
  State<_CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<_CreateGoalDialog> {
  final _title = TextEditingController();
  final _target = TextEditingController();
  final _monthly = TextEditingController();
  String _category = 'Tech & Work Setup';
  DateTime _date = DateTime.now().add(const Duration(days: 90));

  final _categories = const [
    'Tech & Work Setup',
    'Travel & Leisure',
    'Safety & Living Fund',
    'Other',
  ];

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _monthly.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final title = _title.text.trim();
    final target = double.tryParse(_target.text) ?? 0;
    final monthly = double.tryParse(_monthly.text) ?? 0;

    if (title.isEmpty || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title and a target above zero.')),
      );
      return;
    }

    Navigator.pop(
      context,
      Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        category: _category,
        target: target,
        saved: 0,
        monthly: monthly,
        targetDate: _date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Target amount', prefixText: '\$ '),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _monthly,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monthly contribution', prefixText: '\$ '),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text('Target date: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                ),
                TextButton(onPressed: _pickDate, child: const Text('Pick')),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

class _DepositDialog extends StatefulWidget {
  final String goalTitle;
  const _DepositDialog({required this.goalTitle});

  @override
  State<_DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<_DepositDialog> {
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_amount.text) ?? 0;
    if (value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount above zero.')),
      );
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Deposit to ${widget.goalTitle}'),
      content: TextField(
        controller: _amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}