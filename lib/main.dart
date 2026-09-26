import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techwiz7/Screens/add_income.dart';
import 'package:techwiz7/Services/income_sync_service.dart';

import 'package:techwiz7/firebase_options.dart';
import 'package:techwiz7/Authguard.dart';
import 'package:techwiz7/Services/permisions_service.dart';
import 'package:techwiz7/shared/app_colors.dart';

import 'package:techwiz7/Screens/Spalsh.dart';
import 'package:techwiz7/Screens/chose.dart';
import 'package:techwiz7/Screens/Login.dart';
import 'package:techwiz7/Screens/Register.dart';
import 'package:techwiz7/Screens/emailverification.dart';
import 'package:techwiz7/Screens/dashboard.dart';
import 'package:techwiz7/Screens/add_expense.dart';
import 'package:techwiz7/Screens/transaction_history.dart';
import 'package:techwiz7/Screens/budget_planner.dart';
import 'package:techwiz7/Screens/reports_insights.dart';
import 'package:techwiz7/Screens/savings_goals.dart';
import 'package:techwiz7/Screens/learning_hub.dart';
import 'package:techwiz7/Screens/ai_assistant.dart';
import 'package:techwiz7/Screens/notification.dart';
import 'package:techwiz7/Screens/Profile.dart';
import 'package:techwiz7/Screens/Help.dart';
import 'package:techwiz7/Screens/admin/admin_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://rxuxpdeuancbjupzehse.supabase.co',
    anonKey: 'sb_publishable__QzP_6XKXzcG9Euteo4-xA_EneQZFF9',
  );

  permisions().getnotificationpermision();
  IncomeSyncService().start();
  runApp(const PennyPalApp());
}

class PennyPalApp extends StatelessWidget {
  const PennyPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PennyPal',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        fontFamily: 'Roboto',
      ),
      home: Splash(),
      routes: {
        '/home': (context) => Authguard(Dashboard()),
        '/chose': (context) => chose(),
        '/register': (context) => Register(),
        '/login': (context) => Login(),
        '/email': (context) => emailverification(),
        '/dashboard': (context) => Dashboard(),
        '/add-expense': (context) => AddExpense(),
        '/history': (context) => TransactionHistory(),
        '/budget': (context) => BudgetPlanner(),
        '/reports': (context) => InsightsScreen(),
        '/savings': (context) => SavingsGoals(),
        '/learn': (context) => LearningScreen(),
        '/ai': (context) => ChatScreen(),
        '/notification': (context) => NotificationsScreen(),
        '/profile': (context) => ProfileSettingsScreen(),
        '/help': (context) => HelpSupportScreen(),
        '/admin': (context) => AdminMain(),
        '/addincome':(context) => AddIncome()
      },
    );
  }
}
