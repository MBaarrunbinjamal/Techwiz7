import 'package:techwiz7/Models/TransactionModel.dart';
import 'package:techwiz7/Models/goal.dart';

/// Pure calculation helpers for the dashboard.
///
/// No database calls and no Firebase calls live here. Every function takes
/// data in and returns a number or a list.
///
/// Money model:
///   - A goal deposit is recorded as a Savings expense (source 'Savings').
///   - So savings money leaves the wallet through the expenses table.
///   - Available Balance = all income minus all expenses. Savings is already
///     inside expenses, so it is not subtracted again here.
class FinanceCalculator {
  /// Current month key in the same 'YYYY-MM' format the budgets table uses.
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

  /// Available Balance = money earned minus money spent.
  /// Goal deposits are already counted inside expenses, so goals are not
  /// subtracted again. The goals argument stays for callers that pass it.
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