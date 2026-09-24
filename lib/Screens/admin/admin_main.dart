import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'user_management_screen.dart';
import 'support_content_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({Key? key}) : super(key: key);

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  int currentIndex = 0;
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onOpenNotifications: openNotifications, onOpenSettings: openSettings),
      UserManagementScreen(onOpenNotifications: openNotifications, onOpenSettings: openSettings),
      SupportContentScreen(onOpenNotifications: openNotifications, onOpenSettings: openSettings),
      AnalyticsScreen(onOpenNotifications: openNotifications, onOpenSettings: openSettings),
    ];

    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).cardColor,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
              BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
            ],
          ),
        ),
      ),
    );
  }

  void openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          isDark: isDark,
          onToggleTheme: toggleTheme,
        ),
      ),
    );
  }
}