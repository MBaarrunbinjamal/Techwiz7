import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';

import '../Models/users.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create an account, save a profile, and send the verification email.
  // The password is never stored. Firebase Auth keeps it hashed for us.
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );


    final userId = userCredential.user!.uid;
    await FirebaseDatabase.instance.ref('users/$userId').set({
      'FirstName': firstname,
      'LastName': lastname,
      'Email': email,
      'Role': 'User',
    });
    await userCredential.user!.sendEmailVerification();
    final userData = Users(
      FirstName: firstname,
      LastName: lastname,
      email: email,
      password: password,
      userid: userId,
    );

    await DatabaseHelper().insertUser(userData);
    return userCredential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot =
    await FirebaseDatabase.instance.ref('users/${user.uid}').get();

    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }
}


