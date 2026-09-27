import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:techwiz7/Models/support_query.dart';

// All support messages for one student live under support/{uid}/{queryId}.
// Keeping it under the uid lets a security rule scope access to the owner,
// and lets the admin read the whole support node in one place.
class SupportService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  String? get _uid => _auth.currentUser?.uid;

  DatabaseReference? get _rootRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.ref('support/$uid');
  }

  // Create ------------------------------------------------------------

  Future<void> add(SupportQuery query) async {
    final ref = _rootRef;
    if (ref == null) {
      throw Exception('No signed in user');
    }

    await ref.child(query.id).set(query.toMap());
    print('[SUPPORT ADDED] support/$_uid/${query.id} -> ${query.toMap()}');
  }

  // Delete ------------------------------------------------------------

  Future<void> delete(String id) async {
    final ref = _rootRef;
    if (ref == null) {
      throw Exception('No signed in user');
    }

    await ref.child(id).remove();
    print('[SUPPORT DELETED] support/$_uid/$id');
  }

  // Read --------------------------------------------------------------

  // Live list. Use it on an admin screen or to show the student past queries.
  Stream<List<SupportQuery>> watchAll() {
    final ref = _rootRef;
    if (ref == null) return Stream.value(const <SupportQuery>[]);

    return ref.onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null) return <SupportQuery>[];

      final map = Map<String, dynamic>.from(raw as Map);
      final list = map.values
          .map((row) => SupportQuery.fromMap(Map<String, dynamic>.from(row as Map)))
          .toList();

      list.sort((a, b) => b.date.compareTo(a.date)); // newest first
      print('[SUPPORT LIST] ${list.length} record(s)');
      return list;
    });
  }

  // One-time read, for the admin or a report.
  Future<List<SupportQuery>> fetchAll() async {
    final ref = _rootRef;
    if (ref == null) return const <SupportQuery>[];

    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.value == null) return <SupportQuery>[];

    final map = Map<String, dynamic>.from(snapshot.value as Map);
    final list = map.values
        .map((row) => SupportQuery.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
