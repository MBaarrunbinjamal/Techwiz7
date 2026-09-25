import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz7/shared/app_colors.dart';
import 'package:techwiz7/Services/Firebase_Auth_Services.dart';

const _peachColor = Color(0xFFFFE3C4);
const _lavenderColor = Color(0xFFEEF0FB);
const _emptyBarColor = Color(0xFFE0E4F7);
const _lightGreenColor = Color(0xFFDFF5EC);
const _brownColor = Color(0xFFB45309);

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth = AuthService();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _agreed = true;
  bool _isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Fill in your name, email, and password');
      return;
    }
    if (password != confirm) {
      _showMessage('Passwords do not match');
      return;
    }
    if (!_agreed) {
      _showMessage('Please agree to the Terms and Privacy Policy');
      return;
    }

    final parts = name.split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    setState(() => _isLoading = true);
    try {
      await _auth.signUp(email: email, password: password, firstname: firstName, lastname: lastName);
      if (!mounted) return;
      _showMessage('Account created. Check your email to verify.');
      Navigator.pushReplacementNamed(context, '/email');
    } on FirebaseAuthException catch (e) {
      _showMessage(_authMessage(e.code));
    } catch (_) {
      _showMessage('Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Enter a valid email address';
      case 'weak-password':
        return 'Choose a stronger password';
      case 'network-request-failed':
        return 'No internet connection. Check your network';
      default:
        return 'Registration failed. Try again.';
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _topBar(),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heading(),
                  const SizedBox(height: 24),
                  _nameField(),
                  const SizedBox(height: 20),
                  _emailField(),
                  const SizedBox(height: 20),
                  _phoneField(),
                  const SizedBox(height: 20),
                  _passwordField(),
                  const SizedBox(height: 20),
                  _confirmPasswordField(),
                  const SizedBox(height: 20),
                  _termsRow(),
                  const SizedBox(height: 24),
                  _createButton(),
                  const SizedBox(height: 20),
                  _orDivider(),
                  const SizedBox(height: 16),
                  _socialButtons(),
                  const SizedBox(height: 28),
                  _loginLink(),
                  const SizedBox(height: 24),
                  _grantCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _topBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.title),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.savings_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          const Text('PennyPal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        ],
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: _peachColor, borderRadius: BorderRadius.circular(20)),
          child: const Text('BETA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.title)),
        ),
        const SizedBox(width: 16),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _heading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: _peachColor, borderRadius: BorderRadius.circular(20)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 16, color: AppColors.title),
              SizedBox(width: 6),
              Text('NextGen BudgetBee', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.title)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.title, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        const Text('Join PennyPal to start budgeting smarter', style: TextStyle(fontSize: 15.5, color: AppColors.body)),
      ],
    );
  }

  Widget _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Full Name', const Text('Legal or preferred', style: TextStyle(fontSize: 12, color: AppColors.hint))),
        const SizedBox(height: 8),
        TextFormField(controller: fullNameController, style: _inputTextStyle, decoration: _inputDecoration(hint: 'e.g. Alex Johnson', icon: Icons.person_outline_rounded)),
      ],
    );
  }

  Widget _emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Student Email', const Text('Get 50% Off Perks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark))),
        const SizedBox(height: 8),
        TextFormField(controller: emailController, keyboardType: TextInputType.emailAddress, style: _inputTextStyle, decoration: _inputDecoration(hint: 'alex@college.edu', icon: Icons.mail_outline_rounded)),
      ],
    );
  }

  Widget _phoneField() {
    final countryCode = Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: _lavenderColor, borderRadius: BorderRadius.circular(10)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_outlined, size: 18, color: AppColors.body),
            SizedBox(width: 6),
            Text('+1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.title)),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Mobile Number'),
        const SizedBox(height: 8),
        TextFormField(controller: mobileController, keyboardType: TextInputType.phone, style: _inputTextStyle, decoration: _inputDecoration(hint: '(555) 019-2834', prefix: countryCode)),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Password', _strengthChip()),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: _hidePassword,
          style: _inputTextStyle,
          decoration: _inputDecoration(
            hint: '********',
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
              icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.body),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(child: _StrengthBar(AppColors.primary)),
            SizedBox(width: 8),
            Expanded(child: _StrengthBar(AppColors.primary)),
            SizedBox(width: 8),
            Expanded(child: _StrengthBar(AppColors.accent)),
            SizedBox(width: 8),
            Expanded(child: _StrengthBar(_emptyBarColor)),
          ],
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text('Must contain 1 number & 1 special character', style: TextStyle(fontSize: 13, color: AppColors.body)),
        ),
      ],
    );
  }

  Widget _confirmPasswordField() {
    final tick = Center(
      widthFactor: 1,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.only(right: 12),
        decoration: const BoxDecoration(color: _lightGreenColor, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 18, color: AppColors.primaryDark),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Confirm Password'),
        const SizedBox(height: 8),
        TextFormField(controller: confirmController, obscureText: _hideConfirm, style: _inputTextStyle, decoration: _inputDecoration(hint: '********', icon: Icons.lock_reset_rounded, suffix: tick)),
      ],
    );
  }

  Widget _fieldLabel(String text, [Widget? trailing]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.title)),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _strengthChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _peachColor, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: AppColors.accent),
          SizedBox(width: 6),
          Text('Medium strength', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.title)),
        ],
      ),
    );
  }

  Widget _termsRow() {
    const linkStyle = TextStyle(color: AppColors.primaryDark, decoration: TextDecoration.underline, decorationColor: AppColors.primaryDark);
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreed,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (value) => setState(() => _agreed = value ?? false),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: TextStyle(fontSize: 13.5, color: AppColors.body),
              children: [
                TextSpan(text: 'Terms of Service', style: linkStyle),
                TextSpan(text: ' & '),
                TextSpan(text: 'Privacy Policy', style: linkStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _createButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: _isLoading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _orDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR CONTINUE WITH', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.body)),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _socialButtons() {
    final googleLogo = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => const SweepGradient(
        colors: [Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFFBBC05), Color(0xFFEA4335), Color(0xFF4285F4)],
      ).createShader(rect),
      child: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
    );

    return Row(
      children: [
        Expanded(child: _socialButton('Google', googleLogo)),
        const SizedBox(width: 12),
        Expanded(child: _socialButton('Apple', const Icon(Icons.apple, size: 22, color: Colors.black))),
      ],
    );
  }

  Widget _socialButton(String label, Widget icon) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.title)),
          ],
        ),
      ),
    );
  }

  Widget _loginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Already have an account? ', style: TextStyle(fontSize: 15, color: AppColors.body)),
            Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
            Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.primaryDark),
          ],
        ),
      ),
    );
  }

  Widget _grantCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: _peachColor, child: Icon(Icons.workspace_premium_outlined, size: 26, color: _brownColor)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Earn \$10 Student Welcome Grant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.title)),
                SizedBox(height: 4),
                Text('Complete onboarding to unlock your first automatic savings deposit.', style: TextStyle(fontSize: 13.5, height: 1.35, color: AppColors.body)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)));
  }
}

const _inputTextStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.title);

InputDecoration _inputDecoration({required String hint, IconData? icon, Widget? prefix, Widget? suffix}) {
  OutlineInputBorder makeBorder(Color color, [double width = 1]) {
    return OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: width));
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 15, color: AppColors.hint),
    prefixIcon: prefix ?? Icon(icon, color: AppColors.body, size: 22),
    prefixIconConstraints: prefix != null ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    enabledBorder: makeBorder(AppColors.border),
    focusedBorder: makeBorder(AppColors.primary, 1.5),
  );
}
