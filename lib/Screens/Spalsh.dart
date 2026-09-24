import 'package:flutter/material.dart';
import 'package:techwiz7/Screens/Login.dart';

void main() => runApp(const Spalsh());

class Spalsh extends StatelessWidget {
  const Spalsh({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PennyPal',
      home: const SplashScreen(),
      routes: {
        '/login': (context) => Login(),
      },
    );
  }
}

class AppColors {
  static const green = Color(0xFF10B981);
  static const deepGreen = Color(0xFF065F46);
  static const amber = Color(0xFFF59E0B);
  static const amberText = Color(0xFFB45309);
  static const peach = Color(0xFFFDE7C8);
  static const mint = Color(0xFFD1FAE5);
  static const lightBg = Color(0xFFF6F5FF);

  static const darkBg = Color(0xFF0F1A17);
  static const darkPeach = Color(0xFF3B2A10);
  static const darkMint = Color(0xFF0B3D2E);
  static const darkTitle = Color(0xFF6EE7B7);

  static const mutedLight = Color(0xFF64748B);
  static const mutedDark = Color(0xFF94A3B8);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward().whenComplete(_openLogin);
  }

  void _openLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final titleColor = isDark ? AppColors.darkTitle : AppColors.deepGreen;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final chipColor = isDark ? AppColors.darkPeach : AppColors.peach;
    final trackColor = isDark ? AppColors.darkMint : AppColors.mint;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -80,
            child: _glow(260, trackColor),
          ),
          Positioned(
            bottom: -70,
            left: -80,
            child: _glow(240, chipColor),
          ),
          _betaTag(chipColor),
          _centerContent(bgColor, titleColor, mutedColor, chipColor),
          _bottomSection(titleColor, mutedColor, trackColor),
        ],
      ),
    );
  }

  Widget _betaTag(Color chipColor) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, right: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'BETA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: AppColors.amberText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _centerContent(
      Color bgColor,
      Color titleColor,
      Color mutedColor,
      Color chipColor,
      ) {
    return Center(
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _logo(bgColor),
              const SizedBox(height: 26),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Penny',
                      style: TextStyle(color: titleColor),
                    ),
                    const TextSpan(
                      text: 'Pal',
                      style: TextStyle(color: AppColors.green),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Track every penny,\nhive your wealth.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5, color: mutedColor),
              ),
              const SizedBox(height: 22),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '✦ NextGen BudgetBee',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amberText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomSection(Color titleColor, Color mutedColor, Color trackColor) {
    return Positioned(
      left: 32,
      right: 32,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _progressBar(trackColor),
              const SizedBox(height: 12),
              Text(
                'Syncing your student accounts…',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'v1.0.4 · Student Edition',
                style: TextStyle(fontSize: 11, color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(Color trackColor) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 6,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(99),
          ),
          child: FractionallySizedBox(
            widthFactor: Curves.easeOut.transform(_controller.value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: const LinearGradient(
                  colors: [AppColors.green, AppColors.amber],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }

  Widget _logo(Color bgColor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.green, AppColors.deepGreen],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withOpacity(0.35),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: const Icon(
            Icons.savings_rounded,
            size: 66,
            color: Colors.white,
          ),
        ),
        Positioned(
          top: -10,
          right: -14,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.amber,
              shape: BoxShape.circle,
              border: Border.all(color: bgColor, width: 3),
            ),
            child: const Text('🐝', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}