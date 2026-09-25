import 'package:flutter/material.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});
  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int _selectedTab = 0;
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Support', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.info_outline, color: AppColors.green), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _tabBtn(0, 'About PennyPal'),
                  _tabBtn(1, 'Send Feedback / Support'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _selectedTab == 0 ? _aboutTab() : _feedbackTab(),
          ],
        ),
      ),
      bottomNavigationBar: PennyBottomNav(currentIndex: 4),
    );
  }

  Widget _aboutTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.greenTint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greenSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppColors.greenSoft, shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_wallet, color: AppColors.green),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PennyPal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink)),
                      Text('v1.0.4', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                    child: const Text('BudgetBee Ecosystem', style: TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Smart, student-first personal finance and budgeting literacy. Designed to make expense tracking intuitive, zero-stress, and rewarding across your college and early-career journey.',
                style: TextStyle(color: AppColors.ink, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.amberTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.amberSoft),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Educational Disclaimer: PennyPal is a personal finance learning and expense management application. It is not a bank, payment processor, investment broker, or licensed financial advisor.',
                        style: TextStyle(fontSize: 12, color: AppColors.ink, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
        ),
        const SizedBox(height: 12),
        _faqRow('How to set up offline sync'),
        _faqRow('Privacy & data encryption guarantee'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.track),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How is your budgeting experience?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
              const SizedBox(height: 4),
              const Text('Tap a star to rate PennyPal\'s campus budget tools.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: AppColors.amber, size: 32),
                      onPressed: () => setState(() => _rating = i + 1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    );
                  }),
                  const SizedBox(width: 8),
                  const Text('5.0 • Superb', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.amber)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Comments & Reflections', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ink)),
              const SizedBox(height: 8),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell us how PennyPal has helped your campus life or what we can improve...',
                  hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.track),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Contact Student Support', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
        ),
        const SizedBox(height: 12),
        _inputBox('Subject / Topic', 'e.g., Receipt scanner sync question'),
        const SizedBox(height: 12),
        _inputBox('Message', 'Describe your issue or query in detail...', lines: 4),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.track),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.attach_file, color: AppColors.muted),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attach screenshot', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink)),
                    Text('PNG, JPG up to 5MB', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: const BorderSide(color: AppColors.track),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Upload', style: TextStyle(color: AppColors.ink)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback Submitted!')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Submit Feedback & Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(width: 8),
                Icon(Icons.send),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _feedbackTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text('Feedback form goes here', style: TextStyle(color: AppColors.muted)),
      ),
    );
  }

  Widget _tabBtn(int idx, String label) {
    final active = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: active ? [BoxShadow(color: AppColors.track, blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? AppColors.ink : AppColors.muted,
                fontWeight: active ? FontWeight.w800 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _faqRow(String txt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.help_outline, color: AppColors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(txt, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.ink))),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _inputBox(String label, String hint, {int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink)),
        const SizedBox(height: 6),
        TextField(
          maxLines: lines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.track),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}
