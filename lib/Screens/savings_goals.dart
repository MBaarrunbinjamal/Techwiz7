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
  bool _showCompleted = false;

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

  List<Goal> get _active => _goals.where((g) => !g.isArchived).toList();

  List<Goal> get _completed => _goals.where((g) => g.isArchived).toList();

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
      final before = g.reachedMilestone;
      final result = await _service.deposit(g.id, amount, g.saved);
      await _load();
      if (!mounted) return;

      if (result.completed) {
        _showSnack('Goal complete. ${g.title} moved to Completed.');
      } else if (result.milestone > before && result.milestone > 0) {
        _showSnack(
          'Milestone reached: ${result.milestone}% of ${g.title}. \$${amount.toStringAsFixed(2)} added.',
        );
      } else {
        _showSnack('Added \$${amount.toStringAsFixed(2)} to ${g.title}.');
      }
    }
  }

  Future<void> _confirmArchive(Goal g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Archive goal?'),
        content: Text(
          'Move "${g.title}" to Completed. You can restore it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.archive(g.id);
      await _load();
    }
  }

  Future<void> _restore(Goal g) async {
    await _service.restore(g.id);
    await _load();
    if (!mounted) return;
    _showSnack('${g.title} moved back to Active.');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
        ),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PennyPal',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              'Savings Goals',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.textDark,
            ),
            onPressed: _openCreateDialog,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textDark,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
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
            _segmentToggle(),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!_showCompleted) ...[
              if (_active.isEmpty)
                _emptyText('No active goals. Create your first goal.')
              else
                ..._active.map(_buildGoalCard),
            ] else ...[
              if (_completed.isEmpty)
                _emptyText(
                  'No completed goals yet. Reach a target or archive a goal.',
                )
              else
                ..._completed.map(_buildCompletedCard),
            ],
            const SizedBox(height: 20),
            _createGoalButton(),
          ],
        ),
      ),
      bottomNavigationBar: PennyBottomNav(currentIndex: 0),
    );
  }

  Widget _emptyText(String msg) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      ),
    );
  }

  Widget _segmentToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.track,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _segment(
            'Active (${_active.length})',
            !_showCompleted,
                () => setState(() => _showCompleted = false),
          ),
          _segment(
            'Completed (${_completed.length})',
            _showCompleted,
                () => setState(() => _showCompleted = true),
          ),
        ],
      ),
    );
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: selected ? AppColors.primaryDark : AppColors.textMuted,
            ),
          ),
        ),
      ),
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
        showMilestones: true,
        leftIcon: Icons.savings_outlined,
        leftText: 'Contrib: \$${g.monthly.toStringAsFixed(0)}/mo',
        rightText: 'Needs: \$${g.remaining.toStringAsFixed(2)}',
        footerLeft: Text(
          ahead ? 'On track' : '${g.monthsLeft} months left',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
        ),
        footerButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PillButton(
              label: 'Archive',
              icon: Icons.inventory_2_outlined,
              filled: false,
              onTap: () => _confirmArchive(g),
            ),
            const SizedBox(width: 8),
            PillButton(
              label: 'Deposit',
              icon: Icons.add,
              filled: true,
              onTap: () => _openDepositDialog(g),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard(Goal g) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GoalCard(
        iconBg: AppColors.lavender,
        icon: _iconFor(g.category),
        iconColor: AppColors.primaryDark,
        title: g.title,
        subtitle: g.category,
        badgeIcon: Icons.check_circle,
        badgeText: g.isComplete ? 'Achieved' : 'Archived',
        badgeColor: const Color(0xFFDDF3E6),
        badgeTextColor: AppColors.primaryDark,
        current: '\$${g.saved.toStringAsFixed(2)}',
        total: '\$${g.target.toStringAsFixed(2)}',
        percent: g.percent.round(),
        percentBg: const Color(0xFFDDF3E6),
        percentColor: AppColors.primaryDark,
        progressColor: AppColors.primary,
        showMilestones: true,
        leftIcon: Icons.event_available,
        leftText:
        'Target: ${g.targetDate.year}-${g.targetDate.month.toString().padLeft(2, '0')}',
        rightText: 'Saved \$${g.saved.toStringAsFixed(2)}',
        footerLeft: const Row(
          children: [
            Icon(Icons.check_circle, size: 15, color: AppColors.primary),
            SizedBox(width: 5),
            Text(
              'Completed',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
          ],
        ),
        footerButton: PillButton(
          label: 'Restore',
          icon: Icons.undo,
          filled: false,
          onTap: () => _restore(g),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 16,
                    color: AppColors.primaryDark,
                  ),
                  SizedBox(width: 2),
                  Text(
                    '+14% this month',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
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
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                  ),
                ),
                TextSpan(
                  text: '  / \$${_totalTarget.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
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
                  color: AppColors.textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${(_totalTarget - _totalSaved).clamp(0, double.infinity).toStringAsFixed(2)} left',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(
            percent: _overallPercent,
            color: AppColors.primary,
            trackColor: Colors.white,
          ),
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
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
  final _saved = TextEditingController();
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
    _saved.dispose();
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
    final saved = double.tryParse(_saved.text) ?? 0;

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
        saved: saved < 0 ? 0 : saved,
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Target amount',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _monthly,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monthly contribution',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _saved,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Already saved (optional)',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Target date: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                  ),
                ),
                TextButton(onPressed: _pickDate, child: const Text('Pick')),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
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
        decoration: const InputDecoration(
          labelText: 'Amount',
          prefixText: '\$ ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}