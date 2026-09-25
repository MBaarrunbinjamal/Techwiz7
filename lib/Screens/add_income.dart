import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz7/Services/FirebaseSupabaseService.dart';
import 'package:techwiz7/shared/field_box.dart';
import 'package:techwiz7/shared/primary_button.dart';
import 'package:techwiz7/shared/source_chip.dart';
import 'app_colors.dart';

class AddIncome extends StatefulWidget {
  const AddIncome({super.key});

  @override
  State<AddIncome> createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  // ── State fields ─────────────────────────────────────────
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptController = TextEditingController();
  DateTime date = DateTime.now();
  String _source = 'Allowance';
  Future<void> _addincome()async{
    final amount = double.tryParse(_amountController.text.trim());
    final descript = _descriptController.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    final userid = FirebaseAuth.instance.currentUser!.uid;
    final data = {
      'amount': amount,
      'descript': descript,
      'date': date.toIso8601String(),
      'source':  _source,
      'userid': userid,
    };
try{
  await FirebaseSupabaseService().create(tableName: 'income', data: data);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Income added')),
  );
    } catch(e){
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed: $e')),
  );
}
  }


  @override
  void dispose() {
    _amountController.dispose();
    _descriptController.dispose();
    super.dispose();
  }


  void _onAddIncome() {
    final amount = double.tryParse(_amountController.text.trim());
    final descript = _descriptController.text.trim();

    // Validation
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }


    print('Amount: $amount');
    print('Source: $_source');
    print('Date: $date');
    print('descript: $descript');



    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Income added')),
    );

    Navigator.pop(context); // go back if needed
  }

  // ── Date picker ──────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => date = picked);
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _amountCard(),
            const SizedBox(height: 26),

            // ── SOURCE ─────────────────────────────────────
            const Text('Source',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _sourceChip('Allowance', Icons.account_balance_wallet_outlined),
                _sourceChip('Part-time Job', Icons.work_outline_rounded),
                _sourceChip('Scholarship', Icons.school_outlined),
                _sourceChip('Freelance', Icons.laptop_mac_rounded),
                _sourceChip('Gift', Icons.card_giftcard_rounded),
                _sourceChip('Other', Icons.more_horiz_rounded),
              ],
            ),
            const SizedBox(height: 24),

            // ── DATE ───────────────────────────────────────
            const Text('Date',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: FieldBox(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _formatDate(date),
                        style: const TextStyle(
                            color: AppColors.textDark, fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── descript ────────────────────────────────
            const Text('descript',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark)),
            const SizedBox(height: 2),
            const Text('Optional',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 10),
            FieldBox(
              child: TextField(
                controller: _descriptController,   // 👈 bound
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add a note about this income...',
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, fontSize: 13.5),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── SUBMIT BUTTON ──────────────────────────────
            PrimaryButton(
              label: 'Add Income',
              icon: Icons.check_rounded,
              onPressed:_addincome,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() => _source = label),
      child: SourceChip(
        icon: icon,
        label: label,
        selected: _source == label,
      ),
    );
  }

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
        children: [
          const Text('How much did you receive?',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('\$',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark)),
              const SizedBox(width: 6),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,   // 👈 bound
                  textAlign: TextAlign.center,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark),
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: '0.00'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}