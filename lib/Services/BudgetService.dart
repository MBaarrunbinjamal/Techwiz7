
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';
import 'package:techwiz7/Models/BudgetModel.dart';



class BudgetService {
  final _db = DatabaseHelper.instance;

  Future<void> createBudget({
    required String userId,
    required String category,
    required double limit,
    required String month,
  }) async {
    final budget = BudgetModel(
      userId: userId,
      category: category,
      limit: limit,
      month: month,
    );
    await _db.addBudgetAndSync(budget);
  }


  Future<List<BudgetModel>> getBudgets(String userId, {String? month}) async {
    return _db.getBudgets(userId, month: month);
  }

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

  }


  Future<void> refreshAllStatuses(String userId) async {
    final budgets = await _db.getBudgets(userId);
    for (final b in budgets) {
      if (b.id != null) {
        await _db.refreshBudgetStatus(b.id!);
      }
    }
  }


  Future<void> syncPending() async {
    await _db.syncPendingBudgets();
  }
}


class BudgetProgress {
  final BudgetModel budget;
  final double spent;

  BudgetProgress({required this.budget, required this.spent});

  double get remaining => budget.limit - spent;
  double get percentUsed =>
      budget.limit <= 0 ? 0 : (spent / budget.limit).clamp(0, 1);
  bool get isExceeded => spent >= budget.limit;
}