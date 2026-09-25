import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz7/shared/app_colors.dart';
import 'package:techwiz7/Services/Firebase_Auth_Services.dart';
import 'Register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Enter your email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.signIn(email: email, password: password);
      await _auth.reloadUser();
      final user = _auth.currentUser;

      if (!mounted) return;
      if (user != null && user.emailVerified) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage('Please verify your email first');
        Navigator.pushReplacementNamed(context, '/email');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(_authMessage(e.code));
    } catch (_) {
      _showMessage('Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email above, then tap Forgot Password');
      return;
    }
    try {
      await _auth.resetPassword(email);
      _showMessage('Password reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      _showMessage(_authMessage(e.code));
    }
  }

  String _authMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email or password is incorrect';
      case 'invalid-email':
        return 'Enter a valid email address';
      case 'user-disabled':
        return 'This account is disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a few minutes';
      case 'network-request-failed':
        return 'No internet connection. Check your network';
      default:
        return 'Login failed. Try again.';
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _logoHeader(),
                  const SizedBox(height: 32),
                  _loginCard(),
                  const SizedBox(height: 24),
                  _registerLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoHeader() {
    return Column(
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.accent.withValues(alpha: 0.30), blurRadius: 32, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.savings, color: AppColors.green, size: 34),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.wb_sunny_outlined, size: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('PennyPal', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.title, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        const Text(
          'Welcome back! Manage your student\nfinances with ease.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.body),
        ),
      ],
    );
  }

  Widget _loginCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            _gradientStrip(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _emailField(),
                  const SizedBox(height: 20),
                  _passwordField(),
                  const SizedBox(height: 24),
                  _loginButton(),
                  const SizedBox(height: 24),
                  _orDivider(),
                  const SizedBox(height: 20),
                  _socialButtons(),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),
                  _encryptionNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientStrip() {
    return Container(
      height: 5,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent, AppColors.primary]),
      ),
    );
  }

  Widget _emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Email address'),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: _inputTextStyle,
          decoration: _fieldDecoration(hint: 'alex@university.edu', prefix: Icons.mail_outline_rounded),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fieldLabel('Password'),
            GestureDetector(
              onTap: _handleForgotPassword,
              child: const Text('Forgot Password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: _hidePassword,
          style: _inputTextStyle,
          decoration: _fieldDecoration(
            hint: '********',
            prefix: Icons.lock_outline_rounded,
            suffix: IconButton(
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
              icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.body),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Log In', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
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
          child: Text('OR CONTINUE WITH', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.hint)),
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

  Widget _encryptionNote() {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: AppColors.body),
          SizedBox(width: 6),
          Text('Bank-grade 256-bit student data encryption', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.body)),
        ],
      ),
    );
  }

  Widget _registerLink() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Don't have an account?  ", style: TextStyle(fontSize: 14, color: AppColors.body)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Register())),
          child: const Text('Register', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.title));
  }
}

const _inputTextStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.title);

InputDecoration _fieldDecoration({required String hint, required IconData prefix, Widget? suffix}) {
  OutlineInputBorder makeBorder(Color color, [double width = 1]) {
    return OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: width));
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 15, color: AppColors.hint),
    prefixIcon: Icon(prefix, color: AppColors.body, size: 22),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.fieldFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: makeBorder(AppColors.border),
    focusedBorder: makeBorder(AppColors.primary, 1.5),
  );
}
