import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:techwiz7/Models/goal.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';

class GoalService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final DatabaseHelper _local = DatabaseHelper.instance;

  String? get _uid => _auth.currentUser?.uid;

  DatabaseReference? get _rootRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.ref('goals/$uid');
  }

  Future<List<Goal>> getGoals() async {
    final uid = _uid;
    if (uid == null) return [];
    return _local.getGoals(uid);
  }

  Future<void> add(Goal goal) async {
    final uid = _uid;
    if (uid == null) return;
    await _local.insertGoal(goal, uid);
    await _push(goal);
  }

  Future<void> deposit(String id, double amount, double currentSaved) async {
    final uid = _uid;
    if (uid == null) return;
    final newSaved = currentSaved + amount;
    await _local.updateSaved(id, newSaved);
    final goals = await _local.getGoals(uid);
    final g = goals.firstWhere((x) => x.id == id);
    await _push(g);
  }

  Future<void> delete(String id) async {
    await _local.deleteGoal(id);
    final ref = _rootRef;
    if (ref != null) {
      try {
        await ref.child(id).remove();
      } catch (_) {}
    }
  }

  Future<void> _push(Goal g) async {
    final ref = _rootRef;
    if (ref == null) return;
    try {
      await ref.child(g.id).set(g.toMap());
      await _local.markGoalSynced(g.id);
      print('[GOAL SYNCED] goals/$_uid/${g.id}');
    } catch (e) {
      print('[GOAL SYNC FAILED] ${g.id} stays local: $e');
    }
  }

  // Push any local rows that never reached Firebase.
  Future<void> syncPending() async {
    final uid = _uid;
    if (uid == null) return;
    for (final g in await _local.getGoals(uid)) {
      await _push(g);
    }
  }
}