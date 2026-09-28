import 'package:techwiz7/Models/TransactionModel.dart';
import 'package:techwiz7/Models/goal.dart';


class FinanceCalculator {
  static String currentMonthKey({DateTime? now}) {
    final n = now ?? DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}';
  }

  static bool _inMonth(DateTime d, DateTime ref) =>
      d.year == ref.year && d.month == ref.month;

  static double monthlyIncome(List<TransactionModel> txns, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    return txns
        .where((t) => t.type == 'income' && _inMonth(t.date, ref))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double monthlyExpense(List<TransactionModel> txns, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    return txns
        .where((t) => t.type == 'expense' && _inMonth(t.date, ref))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double totalIncome(List<TransactionModel> txns) => txns
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);

  static double totalExpense(List<TransactionModel> txns) => txns
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  static double totalSaved(List<Goal> goals) =>
      goals.fold(0.0, (sum, g) => sum + g.saved);


  static double availableBalance(
      List<TransactionModel> txns,
      List<Goal> goals,
      ) =>
      totalIncome(txns) - totalExpense(txns);

  static List<TransactionModel> recent(
      List<TransactionModel> txns, {
        int count = 3,
      }) {
    final copy = [...txns]..sort((a, b) => b.date.compareTo(a.date));
    return copy.take(count).toList();
  }

  static int daysLeftInMonth({DateTime? now}) {
    final n = now ?? DateTime.now();
    final lastDay = DateTime(n.year, n.month + 1, 0).day;
    return lastDay - n.day;
  }
}