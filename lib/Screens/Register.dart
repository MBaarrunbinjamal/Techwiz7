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
    final phone = mobileController.text.trim();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showMessage('Fill in your name, email, phone, and password');
      return;
    }
    if (password != confirm) {
      _showMessage('Passwords do not match');
      return;
    }

    final firstName = name.split(RegExp(r'\s+')).first;

    setState(() => _isLoading = true);
    try {
      await _auth.signUp(email: email, password: password, firstname: firstName, phone: phone);
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
                  const SizedBox(height: 24),
                  _createButton(),
                  const SizedBox(height: 28),
                  _loginLink(),
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
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.title),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 8),
          const Text('PennyPal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        ],
      ),
      actions: [
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
        _fieldLabel('Full Name'),
        const SizedBox(height: 8),
        TextFormField(controller: fullNameController, style: _inputTextStyle, decoration: _inputDecoration(hint: 'e.g. Alex Johnson', icon: Icons.person_outline_rounded)),
      ],
    );
  }

  Widget _emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Student Email'),
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
            Text('+92', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.title)),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Mobile Number'),
        const SizedBox(height: 8),
        TextFormField(controller: mobileController, keyboardType: TextInputType.phone, style: _inputTextStyle, decoration: _inputDecoration(hint: '300 1234567', prefix: countryCode)),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Password'),
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

  Widget _loginLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
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