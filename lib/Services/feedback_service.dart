import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:techwiz7/Models/app_feedback.dart';

// All feedback for one student lives under feedback/{uid}/{feedbackId}.
// Keeping it under the uid lets a security rule scope access to the owner,
// and lets the admin read the whole feedback node in one place.
class FeedbackService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  String? get _uid => _auth.currentUser?.uid;

  DatabaseReference? get _rootRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.ref('feedback/$uid');
  }

  // Create ------------------------------------------------------------

  Future<void> add(AppFeedback feedback) async {
    final ref = _rootRef;
    if (ref == null) {
      throw Exception('No signed in user');
    }

    await ref.child(feedback.id).set(feedback.toMap());
    print('[FEEDBACK ADDED] feedback/$_uid/${feedback.id} -> ${feedback.toMap()}');
  }

  // Delete ------------------------------------------------------------

  Future<void> delete(String id) async {
    final ref = _rootRef;
    if (ref == null) {
      throw Exception('No signed in user');
    }

    await ref.child(id).remove();
    print('[FEEDBACK DELETED] feedback/$_uid/$id');
  }

  // Read --------------------------------------------------------------

  // Live list. The UI rebuilds whenever the database changes.
  Stream<List<AppFeedback>> watchAll() {
    final ref = _rootRef;
    if (ref == null) return Stream.value(const <AppFeedback>[]);

    return ref.onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null) return <AppFeedback>[];

      final map = Map<String, dynamic>.from(raw as Map);
      final list = map.values
          .map((row) => AppFeedback.fromMap(Map<String, dynamic>.from(row as Map)))
          .toList();

      list.sort((a, b) => b.date.compareTo(a.date)); // newest first
      print('[FEEDBACK LIST] ${list.length} record(s)');
      return list;
    });
  }

  // One-time read, for the admin or a report.
  Future<List<AppFeedback>> fetchAll() async {
    final ref = _rootRef;
    if (ref == null) return const <AppFeedback>[];

    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.value == null) return <AppFeedback>[];

    final map = Map<String, dynamic>.from(snapshot.value as Map);
    final list = map.values
        .map((row) => AppFeedback.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
