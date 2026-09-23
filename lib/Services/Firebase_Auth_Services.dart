import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname
  }) async {
    final userCredential =  await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user!.sendEmailVerification();
    final userid = await userCredential.user!.uid;
    final collection = FirebaseDatabase.instance.ref('users/$userid');
    collection.push().set({
     "FirstName":firstname,
      "LastName":lastname,
      "Email":email,
      "password":password,
      "Role":"User",
      // "token":token

    });
    return userCredential;
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,

  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Reload current user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Delete current account
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
