import 'package:flutter/material.dart';
import 'package:techwiz7/shared/app_colors.dart';

/// One bottom navigation bar for the whole student app.
/// Each tab maps to a named route. Pass the index of the current screen.
/// A docked AI Advice button sits just above the tabs on every screen.
class PennyBottomNav extends StatelessWidget {
  final int currentIndex;

  const PennyBottomNav({super.key, required this.currentIndex});

  static const _routes = [
    '/home',
    '/history',
    '/about',
    '/learn',
    '/reports',
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  void _openAi(BuildContext context) {
    Navigator.pushNamed(context, '/ai');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _aiButton(context),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.track)),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (i) => _onTap(context, i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.green,
            unselectedItemColor: AppColors.muted,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About'),
              BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Learn'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _aiButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 16, 10),
        child: GestureDetector(
          onTap: () => _openAi(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'AI Advice',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}