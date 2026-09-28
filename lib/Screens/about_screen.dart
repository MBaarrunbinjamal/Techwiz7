import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:techwiz7/Models/app_feedback.dart';
import 'package:techwiz7/Models/support_query.dart';
import 'package:techwiz7/Services/feedback_service.dart';
import 'package:techwiz7/Services/support_service.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int _selectedTab = 0;
  int _rating = 5;

  final FeedbackService _feedbackService = FeedbackService();
  final SupportService _supportService = SupportService();

  // Feedback form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  bool _savingFeedback = false;

  // Contact support form
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _savingContact = false;

  // Signed in user, read once from the users node
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentsController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Load user ---------------------------------------------------------

  // Reads the same users node your dashboard greeting uses, so the name
  // on every feedback and support record matches the rest of the app.
  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _userEmail = user.email ?? '';
    try {
      final snapshot =
          await FirebaseDatabase.instance.ref('users/${user.uid}').get();
      if (snapshot.exists && snapshot.value != null) {
        final map = Map<String, dynamic>.from(snapshot.value as Map);
        _userName =
            (map['fullName'] as String?) ?? (map['name'] as String?) ?? '';
      }
    } catch (_) {
      // Ignore, the form still works with the email alone.
    }

    if (!mounted) return;
    setState(() {
      _nameController.text = _userName;
      _emailController.text = _userEmail;
    });
  }

  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      default:
        return 'Superb';
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // Submit feedback ---------------------------------------------------

  Future<void> _onSubmitFeedback() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final comments = _commentsController.text.trim();

    if (name.isEmpty) {
      _showMessage('Enter your name');
      return;
    }
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(email);
    if (!emailOk) {
      _showMessage('Enter a valid email');
      return;
    }
    if (comments.isEmpty) {
      _showMessage('Enter your comments');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final feedback = AppFeedback(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      email: email,
      rating: _rating,
      comments: comments,
      userId: user?.uid ?? '',
      date: now,
    );

    setState(() => _savingFeedback = true);
    try {
      await _feedbackService.add(feedback);
      if (!mounted) return;

      _commentsController.clear();
      FocusScope.of(context).unfocus();
      setState(() => _rating = 5);
      _showMessage('Feedback submitted. Thank you.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not submit: $e');
    } finally {
      if (mounted) setState(() => _savingFeedback = false);
    }
  }

  // Submit contact support --------------------------------------------

  Future<void> _onSubmitContact() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty) {
      _showMessage('Enter a subject');
      return;
    }
    if (message.isEmpty) {
      _showMessage('Enter your message');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final query = SupportQuery(
      id: now.microsecondsSinceEpoch.toString(),
      subject: subject,
      message: message,
      userId: user?.uid ?? '',
      userName: _userName,
      userEmail: _userEmail.isNotEmpty ? _userEmail : (user?.email ?? ''),
      status: 'open',
      date: now,
    );

    setState(() => _savingContact = true);
    try {
      await _supportService.add(query);
      if (!mounted) return;

      _subjectController.clear();
      _messageController.clear();
      FocusScope.of(context).unfocus();
      _showMessage('Message sent to support.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not send: $e');
    } finally {
      if (mounted) setState(() => _savingContact = false);
    }
  }

  // Build -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('About PennyPal',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: AppColors.ink),
                  onPressed: () => Navigator.pushNamed(context, '/notification'),
                ),
                Positioned(
                  right: 8,
                  top: 8,
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
          ),
        ],
      ),      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _tabBtn(0, 'About PennyPal'),
                  _tabBtn(1, 'Feedback & Support'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _selectedTab == 0 ? _aboutTab() : _feedbackTab(),
          ],
        ),
      ),
      bottomNavigationBar: PennyBottomNav(currentIndex: 2),    );
  }

  // TAB 0: ABOUT ------------------------------------------------------

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
                    decoration: const BoxDecoration(
                        color: AppColors.greenSoft, shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_wallet,
                        color: AppColors.green),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PennyPal',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.ink)),
                      Text('v1.0.4',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('BudgetBee Ecosystem',
                        style: TextStyle(
                            color: AppColors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'PennyPal helps students take control of their money. Track daily expenses, set budgets, and build strong money habits from your first year of college into your early career.',
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
                        style: TextStyle(
                            fontSize: 12, color: AppColors.ink, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Purpose section
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Why PennyPal Exists',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.ink)),
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Most students never learn how to manage money before they need to. PennyPal closes that gap with a simple, low-pressure tool built around student life and student budgets.',
            style: TextStyle(color: AppColors.muted, height: 1.5, fontSize: 13),
          ),
        ),
        const SizedBox(height: 16),
        _featureRow(Icons.receipt_long, 'Track every expense',
            'Log spending in seconds and see where your money goes.'),
        _featureRow(Icons.pie_chart_outline, 'Set and follow budgets',
            'Build category budgets that fit a student income.'),
        _featureRow(Icons.trending_up, 'Build money habits',
            'Spot patterns early and stay on top of your goals.'),
        _featureRow(Icons.school_outlined, 'Learn as you go',
            'Grow your financial literacy through daily use.'),

        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Frequently Asked Questions',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.ink)),
        ),
        const SizedBox(height: 12),
        _faqRow('How to set up offline sync'),
        _faqRow('Privacy & data encryption guarantee'),
        const SizedBox(height: 30),
      ],
    );
  }

  // TAB 1: FEEDBACK & SUPPORT -----------------------------------------

  Widget _feedbackTab() {
    return Column(
      children: [
        // Feedback card
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
              const Text('Send Feedback',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.ink)),
              const SizedBox(height: 4),
              const Text('Tell us how PennyPal is working for you.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 16),
              _label('Name'),
              _field(_nameController, 'Your full name'),
              const SizedBox(height: 12),
              _label('Email'),
              _field(_emailController, 'you@example.com',
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _label('Rating'),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(i < _rating ? Icons.star : Icons.star_border,
                          color: AppColors.amber, size: 32),
                      onPressed: () => setState(() => _rating = i + 1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text('$_rating.0 • $_ratingLabel',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber)),
                ],
              ),
              const SizedBox(height: 16),
              _label('Comments'),
              _field(_commentsController,
                  'Tell us what helped or what we should improve...',
                  lines: 3),
              const SizedBox(height: 16),
              _submitButton(
                label: 'Submit Feedback',
                saving: _savingFeedback,
                onPressed: _onSubmitFeedback,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Contact support card
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
              const Text('Contact Student Support',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.ink)),
              const SizedBox(height: 4),
              const Text('We reply to your registered email.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 12),
              // Signed in user banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.greenTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.greenSoft),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppColors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName.isNotEmpty ? _userName : 'Signed in',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.ink),
                          ),
                          Text(
                            _userEmail.isNotEmpty
                                ? _userEmail
                                : 'No email on account',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _label('Subject / Topic'),
              _field(_subjectController, 'e.g., Receipt scanner sync question'),
              const SizedBox(height: 12),
              _label('Message'),
              _field(_messageController,
                  'Describe your issue or query in detail...',
                  lines: 4),
              const SizedBox(height: 16),
              _submitButton(
                label: 'Send Message',
                saving: _savingContact,
                onPressed: _onSubmitContact,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // Shared widgets ----------------------------------------------------

  Widget _submitButton({
    required String label,
    required bool saving,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: saving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  const Icon(Icons.send, size: 18),
                ],
              ),
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
            boxShadow: active
                ? [
                    BoxShadow(
                        color: AppColors.track,
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
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

  Widget _featureRow(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12, height: 1.3)),
              ],
            ),
          ),
        ],
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
            decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.help_outline,
                color: AppColors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(txt,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.ink))),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink)),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    int lines = 1,
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: controller,
      maxLines: lines,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.track),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.track),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
