import 'package:flutter/material.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';
import 'package:techwiz7/Models/expense.dart';
import 'package:techwiz7/Services/PrefsService.dart';
import 'app_colors.dart';

class AddExpense extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddExpense();
  }
}

class _AddExpense extends State<AddExpense> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();

  List<expense> _expenseList = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.lunch_dining},
    {'name': 'Transport', 'icon': Icons.directions_bus},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Fun', 'icon': Icons.movie_outlined},
    {'name': 'Bills', 'icon': Icons.receipt_long},
    {'name': 'Savings', 'icon': Icons.savings},
    {'name': 'Misc', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _loadexpenses();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadexpenses() async {
    setState(() => _isLoading = true);

    final userId = await PrefsService.instance.getUserId();

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _expenseList = [];
        _isLoading = false;
      });

      return;
    }

    try {
      debugPrint('Loading expenses for Firebase UID: $userId');

      final expenses = await DatabaseHelper().getexpense(userId);

      if (!mounted) return;

      setState(() {
        _expenseList = expenses;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading expenses: $e');

      if (!mounted) return;

      setState(() {
        _expenseList = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExpense(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text(
          'Yeh expense permanently delete ho jayega.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await DatabaseHelper().deleteexpense(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense deleted'),
        ),
      );

      await _loadexpenses();
    } catch (e) {
      debugPrint('Error deleting expense: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete expense: $e'),
        ),
      );
    }
  }

  Map<String, dynamic> _buildExpenseData() {
    return {
      'amount': double.tryParse(
        _amountController.text.trim(),
      ) ??
          0.0,
      'category': _selectedCategory,
      'date': _selectedDate.toIso8601String(),
      'description': _descriptionController.text.trim(),
    };
  }

  Future<void> _onSavePressed() async {
    final amount = double.tryParse(
      _amountController.text.trim(),
    ) ??
        0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
        ),
      );
      return;
    }

    // No category is selected by default now, so make sure one is picked.
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
        ),
      );
      return;
    }

    final userId = await PrefsService.instance.getUserId();

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in'),
        ),
      );

      return;
    }

    debugPrint('Saving expense for Firebase UID: $userId');

    final newExpense = expense(
      amount: amount,
      source: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
      userid: userId,
      status: 'pending',
    );

    try {
      await DatabaseHelper().addexpenseAndSync(newExpense);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Expense saved: ${newExpense.source} \$${newExpense.amount.toStringAsFixed(2)}',
          ),
        ),
      );

      await _loadexpenses();
    } catch (e) {
      debugPrint('Error saving expense: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${d.day} ${months[d.month - 1]}, ${d.year}';
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
              _header(),
              const SizedBox(height: 20),
              _amountBlock(),
              const SizedBox(height: 20),
              // AI pill only shows once a category is chosen.
              if (_selectedCategory.isNotEmpty) ...[
                _aiPill(),
                const SizedBox(height: 22),
              ],
              _categorySection(),
              const SizedBox(height: 22),
              _label('Date'),
              const SizedBox(height: 8),
              _dateField(),
              const SizedBox(height: 18),
              _label('Description'),
              const SizedBox(height: 8),
              _descriptionField(),
              const SizedBox(height: 20),
              _saveButton(),
              const SizedBox(height: 28),
              _expenseListSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expenseListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Expenses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_expenseList.isEmpty && !_isLoading)
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.track,
              ),
            ),
            child: const Center(
              child: Text(
                'No expenses yet',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ),
          )
        else
          ..._expenseList.map(
                (e) => _expenseTile(e),
          ),
      ],
    );
  }

  Widget _expenseTile(expense e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.track,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForCategory(e.source),
              size: 20,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.source,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  e.description.isEmpty
                      ? 'No description'
                      : e.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${e.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(e.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.muted,
            ),
            onPressed: () {
              if (e.id != null) {
                _deleteExpense(e.id!);
              }
            },
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String name) {
    final match = _categories.firstWhere(
          (c) => c['name'] == name,
      orElse: () => {
        'name': 'Misc',
        'icon': Icons.more_horiz,
      },
    );

    return match['icon'] as IconData;
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: const Icon(
            Icons.arrow_back,
            size: 24,
            color: AppColors.ink,
          ),
        ),
        const Expanded(
          child: Text(
            'Add Expense',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: const Icon(
            Icons.close,
            size: 24,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _amountBlock() {
    return Column(
      children: [
        const Text(
          'EXPENSE AMOUNT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '\$',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 6),
            IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _quickAdd('+\$5', 5),
            const SizedBox(width: 10),
            _quickAdd('+\$10', 10),
            const SizedBox(width: 10),
            _quickAdd('+\$20', 20),
          ],
        ),
      ],
    );
  }

  Widget _quickAdd(String text, double value) {
    return GestureDetector(
      onTap: () {
        final current =
            double.tryParse(_amountController.text.trim()) ?? 0.0;

        final updated = current + value;

        _amountController.text =
            updated.toStringAsFixed(2);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.blueSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
          ),
        ),
      ),
    );
  }

  Widget _aiPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.amberSoft,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 15,
              color: AppColors.amber,
            ),
            const SizedBox(width: 6),
            const Text(
              'AI Auto-Categorized: ',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.ink,
              ),
            ),
            Text(
              '$_selectedCategory  ',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.amber,
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tap a category below to change',
                    ),
                  ),
                );
              },
              child: const Text(
                'Change',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Select Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Spacer(),
            Text(
              '8 Categories',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: _buildCategoryRow(0, 4),
        ),
        const SizedBox(height: 12),
        Row(
          children: _buildCategoryRow(4, 8),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryRow(int start, int end) {
    final List<Widget> tiles = [];

    for (int i = start; i < end; i++) {
      final cat = _categories[i];

      final isSelected =
          _selectedCategory == cat['name'];

      tiles.add(
        _catTile(
          cat['icon'] as IconData,
          cat['name'] as String,
          selected: isSelected,
        ),
      );

      if (i != end - 1) {
        tiles.add(
          const SizedBox(width: 12),
        );
      }
    }

    return tiles;
  }

  Widget _catTile(
      IconData icon,
      String label, {
        bool selected = false,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.green
                  : AppColors.track,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.greenSoft
                      : AppColors.purpleSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? AppColors.green
                      : AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.green
                      : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
    );
  }

  Widget _dateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.track,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.green,
            ),
            const SizedBox(width: 12),
            Text(
              _formatDate(_selectedDate),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _descriptionField() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.track,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _descriptionController,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Add a note (optional)',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          const Icon(
            Icons.edit_note,
            size: 20,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onSavePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
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
          Icons.check,
          size: 20,
        ),
        label: const Text(
          'Save Expense',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}