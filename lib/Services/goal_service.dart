import 'package:firebase_database/firebase_database.dart';
import 'package:techwiz7/Models/goal.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';
import 'package:techwiz7/Services/PrefsService.dart';


class DepositResult {
  final int milestone;
  final bool completed;
  DepositResult({required this.milestone, required this.completed});
}

class GoalService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final DatabaseHelper _local = DatabaseHelper.instance;


  Future<String?> _uid() => PrefsService.instance.getUserId();

  Future<List<Goal>> getGoals() async {
    final uid = await _uid();
    if (uid == null || uid.isEmpty) return [];
    return _local.getGoals(uid);
  }

  Future<void> add(Goal goal) async {
    final uid = await _uid();
    if (uid == null || uid.isEmpty) return;
    await _local.insertGoal(goal, uid);
    await _push(uid, goal);
  }


  Future<DepositResult> deposit(
      String id,
      double amount,
      double currentSaved,
      ) async {
    final uid = await _uid();
    if (uid == null || uid.isEmpty) {
      return DepositResult(milestone: 0, completed: false);
    }


    final newSaved = currentSaved + amount;
    await _local.updateSaved(id, newSaved);


    final goals = await _local.getGoals(uid);
    final match = goals.where((x) => x.id == id).toList();
    final title = match.isNotEmpty ? match.first.title : 'goal';


    await _local.addSavingsExpense(
      userId: uid,
      amount: amount,
      goalTitle: title,
      date: DateTime.now(),
    );


    int reached = 0;
    bool completed = false;
    if (match.isNotEmpty) {
      final g = match.first;
      reached = g.reachedMilestone;
      completed = g.isComplete;
      await _local.updateGoalMeta(
        id,
        milestone: reached,
        status: completed ? 'archived' : null,
      );
      final after = await _local.getGoals(uid);
      final refreshed = after.where((x) => x.id == id).toList();
      if (refreshed.isNotEmpty) await _push(uid, refreshed.first);
    }

    return DepositResult(milestone: reached, completed: completed);
  }

  Future<void> archive(String id) async {
    await _local.updateGoalMeta(id, status: 'archived');
    await _pushById(id);
  }

  Future<void> restore(String id) async {
    await _local.updateGoalMeta(id, status: 'active');
    await _pushById(id);
  }

  Future<void> delete(String id) async {
    final uid = await _uid();
    await _local.deleteGoal(id);
    if (uid == null || uid.isEmpty) return;
    try {
      await _db.ref('goals/$uid/$id').remove();
    } catch (_) {}
  }

  Future<void> _pushById(String id) async {
    final uid = await _uid();
    if (uid == null || uid.isEmpty) return;
    final list = await _local.getGoals(uid);
    final match = list.where((x) => x.id == id).toList();
    if (match.isNotEmpty) await _push(uid, match.first);
  }

  Future<void> _push(String uid, Goal g) async {
    try {
      await _db.ref('goals/$uid/${g.id}').set(g.toMap());
      await _local.markGoalSynced(g.id);
      print('[GOAL SYNCED] goals/$uid/${g.id}');
    } catch (e) {
      print('[GOAL SYNC FAILED] ${g.id} stays local: $e');
    }
  }

  Future<void> syncPending() async {
    final uid = await _uid();
    if (uid == null || uid.isEmpty) return;
    for (final g in await _local.getGoals(uid)) {
      await _push(uid, g);
    }
  }
}