
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';
import 'package:techwiz7/shared/field_box.dart';
import 'package:techwiz7/shared/primary_button.dart';
import 'package:techwiz7/shared/source_chip.dart';
import 'app_colors.dart';
import 'package:techwiz7/Models/income.dart';

class AddIncome extends StatefulWidget {
const AddIncome({super.key});

@override
State<AddIncome> createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
final TextEditingController _amountController = TextEditingController();
final TextEditingController _descriptionController =
TextEditingController();

List<Income> _incomeList = [];

String _source = 'Allowance';

static const List<_SourceOption> _sources = [
_SourceOption('Allowance', Icons.account_balance_wallet_outlined),
_SourceOption('Part-time Job', Icons.work_outline_rounded),
_SourceOption('Scholarship', Icons.school_outlined),
_SourceOption('Freelance', Icons.laptop_mac_rounded),
_SourceOption('Gift', Icons.card_giftcard_rounded),
_SourceOption('Other', Icons.more_horiz_rounded),
];

@override
void initState() {
super.initState();
_loadIncomes();
}

@override
void dispose() {
_amountController.dispose();
_descriptionController.dispose();
super.dispose();
}

Future<void> _loadIncomes() async {
final user = await DatabaseHelper().getuserid();

if (user == null) {
if (!mounted) return;

setState(() {
_incomeList = [];
});

return;
}

final incomes = await DatabaseHelper().getIncomes(user.userId);

if (!mounted) return;

setState(() {
_incomeList = incomes;
});
}

Future<void> _onAddIncome() async {
final amount = double.tryParse(
_amountController.text.trim(),
);

final description = _descriptionController.text.trim();

if (amount == null || amount <= 0) {
_showMessage('Enter a valid amount');
return;
}

final user = await DatabaseHelper().getuserid();

if (user == null) {
_showMessage('User not found');
return;
}

final income = Income(
amount: amount,
description: description,
source: _source,
userid: user.userId,
status: 'pending',
date: DateTime.now(),
);

try {
await DatabaseHelper().addincome(income);

await _loadIncomes();

_amountController.clear();
_descriptionController.clear();

FocusScope.of(context).unfocus();

_showMessage(
'Income of ${_money(amount)} added',
);
} catch (e) {
_showMessage('Failed to add income');
}
}

Future<void> _onDeleteIncome(Income income) async {
final confirmed = await showDialog<bool>(
context: context,
builder: (context) => AlertDialog(
title: const Text('Delete income'),
content: Text(
'Remove ${_money(income.amount)} from ${income.source}?',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context, false),
child: const Text('Cancel'),
),
TextButton(
onPressed: () => Navigator.pop(context, true),
child: const Text(
'Delete',
style: TextStyle(color: Colors.redAccent),
),
),
],
),
);

if (confirmed != true) return;

if (income.id == null) return;

try {
await DatabaseHelper().deleteIncome(income.id!);
await _loadIncomes();

_showMessage('Income deleted');
} catch (e) {
_showMessage('Failed to delete income');
}
}

void _showMessage(String text) {
ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
content: Text(text),
),
);
}

String _money(double value) {
return '\$${value.toStringAsFixed(2)}';
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
'Dec',
];

return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String _formatTime(DateTime d) {
final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
final minute = d.minute.toString().padLeft(2, '0');
final period = d.hour < 12 ? 'AM' : 'PM';

return '$hour:$minute $period';
}

double get _totalIncome {
return _incomeList.fold<double>(
0,
(sum, income) => sum + income.amount,
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
backgroundColor: AppColors.background,
elevation: 0,
leading: const BackButton(
color: AppColors.textDark,
),
centerTitle: true,
title: const Text(
'Add Income',
style: TextStyle(
color: AppColors.textDark,
fontWeight: FontWeight.w800,
fontSize: 18,
),
),
),
body: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
16,
8,
16,
32,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_amountCard(),
const SizedBox(height: 26),
_label('Source'),
const SizedBox(height: 10),
Wrap(
spacing: 10,
runSpacing: 10,
children: _sources
    .map(
(option) => _sourceChip(
option.label,
option.icon,
),
)
    .toList(),
),
const SizedBox(height: 24),
_label('Date'),
const SizedBox(height: 2),
const Text(
'Set automatically when you save',
style: TextStyle(
color: AppColors.textMuted,
fontSize: 12,
),
),
const SizedBox(height: 10),
_dateBox(),
const SizedBox(height: 24),
_label('Description'),
const SizedBox(height: 2),
const Text(
'Optional',
style: TextStyle(
color: AppColors.textMuted,
fontSize: 12,
),
),
const SizedBox(height: 10),
FieldBox(
child: TextField(
controller: _descriptionController,
maxLines: 3,
textInputAction: TextInputAction.done,
decoration: const InputDecoration(
border: InputBorder.none,
hintText: 'Add a note about this income...',
hintStyle: TextStyle(
color: AppColors.textMuted,
fontSize: 13.5,
),
),
),
),
const SizedBox(height: 28),
PrimaryButton(
label: 'Add Income',
icon: Icons.check_rounded,
onPressed: _onAddIncome,
),
const SizedBox(height: 34),
_historyHeader(),
const SizedBox(height: 12),
_historyList(),
],
),
),
);
}

Widget _label(String text) {
return Text(
text,
style: const TextStyle(
fontWeight: FontWeight.w700,
fontSize: 15,
color: AppColors.textDark,
),
);
}

Widget _dateBox() {
final now = DateTime.now();

return FieldBox(
child: Row(
children: [
const Icon(
Icons.calendar_today_rounded,
size: 18,
color: AppColors.textMuted,
),
const SizedBox(width: 10),
Expanded(
child: Text(
_formatDate(now),
style: const TextStyle(
color: AppColors.textDark,
fontSize: 14,
),
),
),
const Icon(
Icons.lock_outline_rounded,
size: 16,
color: AppColors.textMuted,
),
],
),
);
}

Widget _sourceChip(String label, IconData icon) {
return GestureDetector(
onTap: () {
setState(() {
_source = label;
});
},
child: SourceChip(
icon: icon,
label: label,
selected: _source == label,
),
);
}

Widget _amountCard() {
return Container(
padding: const EdgeInsets.symmetric(
vertical: 28,
horizontal: 20,
),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: AppColors.cardBorder,
),
gradient: const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFFE9F7F0),
Color(0xFFFDF1E4),
],
),
),
child: Column(
children: [
const Text(
'How much did you receive?',
style: TextStyle(
color: AppColors.textMuted,
fontSize: 13,
),
),
const SizedBox(height: 10),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
'\$',
style: TextStyle(
fontSize: 30,
fontWeight: FontWeight.w800,
color: AppColors.primaryDark,
),
),
const SizedBox(width: 6),
IntrinsicWidth(
child: TextField(
controller: _amountController,
textAlign: TextAlign.center,
keyboardType:
const TextInputType.numberWithOptions(
decimal: true,
),
inputFormatters: [
FilteringTextInputFormatter.allow(
RegExp(r'^\d*\.?\d{0,2}'),
),
],
style: const TextStyle(
fontSize: 38,
fontWeight: FontWeight.w800,
color: AppColors.textDark,
),
decoration: const InputDecoration(
border: InputBorder.none,
hintText: '0.00',
),
),
),
],
),
],
),
);
}

Widget _historyHeader() {
return Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
crossAxisAlignment: CrossAxisAlignment.end,
children: [
_label('Your Income'),
Text(
'Total ${_money(_totalIncome)}',
style: const TextStyle(
fontWeight: FontWeight.w700,
fontSize: 14,
color: AppColors.primaryDark,
),
),
],
);
}

Widget _historyList() {
if (_incomeList.isEmpty) {
return Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
vertical: 30,
horizontal: 16,
),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: AppColors.cardBorder,
),
),
child: const Column(
children: [
Icon(
Icons.receipt_long_rounded,
size: 30,
color: AppColors.textMuted,
),
SizedBox(height: 10),
Text(
'No income recorded yet',
style: TextStyle(
color: AppColors.textMuted,
fontSize: 13.5,
),
),
],
),
);
}

return Column(
children: _incomeList.map(_incomeTile).toList(),
);
}

Widget _incomeTile(Income income) {
return Container(
margin: const EdgeInsets.only(bottom: 10),
padding: const EdgeInsets.symmetric(
vertical: 14,
horizontal: 14,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: AppColors.cardBorder,
),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: const Color(0xFFE9F7F0),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
_iconForSource(income.source),
size: 19,
color: AppColors.primaryDark,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
income.source,
style: const TextStyle(
fontWeight: FontWeight.w700,
fontSize: 14.5,
color: AppColors.textDark,
),
),
const SizedBox(height: 3),
Text(
'${_formatDate(income.date)}, ${_formatTime(income.date)}',
style: const TextStyle(
color: AppColors.textMuted,
fontSize: 12,
),
),
if (income.description.isNotEmpty) ...[
const SizedBox(height: 6),
Text(
income.description,
style: const TextStyle(
color: AppColors.textDark,
fontSize: 13,
),
),
],
],
),
),
const SizedBox(width: 10),
Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
'+ ${_money(income.amount)}',
style: const TextStyle(
fontWeight: FontWeight.w800,
fontSize: 15,
color: AppColors.primaryDark,
),
),
const SizedBox(height: 2),
InkWell(
onTap: () => _onDeleteIncome(income),
borderRadius: BorderRadius.circular(8),
child: const Padding(
padding: EdgeInsets.all(4),
child: Icon(
Icons.delete_outline_rounded,
size: 19,
color: Colors.redAccent,
),
),
),
],
),
],
),
);
}

IconData _iconForSource(String source) {
return _sources
    .firstWhere(
(option) => option.label == source,
orElse: () => _sources.last,
)
    .icon;
}
}

class _SourceOption {
final String label;
final IconData icon;

const _SourceOption(
this.label,
this.icon,
);
}

