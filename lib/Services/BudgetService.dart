
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';
import 'package:techwiz7/Models/BudgetModel.dart';



class BudgetService {
  final _db = DatabaseHelper.instance;

  Future<void> createBudget({
    required String userId,
    required String category,
    required double limit,
    required String month, // 'YYYY-MM'
  }) async {
    final budget = BudgetModel(
      userId: userId,
      category: category,
      limit: limit,
      month: month,
    );
    await _db.addBudgetAndSync(budget);
  }

  /// All budgets for a user, optionally filtered to one month.
  /// Call refreshAllStatuses() first if you want up-to-date 'exceeded' flags.
  Future<List<BudgetModel>> getBudgets(String userId, {String? month}) async {
    return _db.getBudgets(userId, month: month);
  }

  /// Each budget paired with its live spent amount — this is what the
  /// UI progress bar / "PKR X of Y spent" text should bind to.
  Future<List<BudgetProgress>> getBudgetsWithProgress(
      String userId, {
        String? month,
      }) async {
    final budgets = await _db.getBudgets(userId, month: month);
    final result = <BudgetProgress>[];
    for (final b in budgets) {
      final spent = await _db.getBudgetSpent(userId, b.category, b.month);
      result.add(BudgetProgress(budget: b, spent: spent));
    }
    return result;
  }

  Future<void> updateLimit(int id, double newLimit) async {
    await _db.updateBudgetLimit(id, newLimit);
    await _db.syncBudget(id);
  }

  Future<void> deleteBudget(int id) async {
    await _db.deleteBudget(id);
    // No remote delete call exists yet for other tables either (income/
    // expense/goals only ever push updates) — add one here if you later
    // need deletes to remove the Firebase node too.
  }

  /// Recomputes 'active'/'exceeded' for every budget this user has.
  /// Call this on the budget screen's initState, and after any income/
  /// expense add already triggers it automatically via DatabaseHelper.
  Future<void> refreshAllStatuses(String userId) async {
    final budgets = await _db.getBudgets(userId);
    for (final b in budgets) {
      if (b.id != null) {
        await _db.refreshBudgetStatus(b.id!);
      }
    }
  }

  /// Push everything still marked unsynced. Call on app start and
  /// whenever connectivity comes back.
  Future<void> syncPending() async {
    await _db.syncPendingBudgets();
  }
}

/// Pairs a budget with how much of it has actually been spent —
/// convenient for driving a progress bar in the UI.
class BudgetProgress {
  final BudgetModel budget;
  final double spent;

  BudgetProgress({required this.budget, required this.spent});

  double get remaining => budget.limit - spent;
  double get percentUsed =>
      budget.limit <= 0 ? 0 : (spent / budget.limit).clamp(0, 1);
  bool get isExceeded => spent >= budget.limit;
}