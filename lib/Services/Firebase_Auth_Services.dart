import 'package:bcrypt/bcrypt.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';
import 'package:techwiz7/Services/PrefsService.dart';
import '../Models/users.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();


  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstname,
    required String phone,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userId = userCredential.user!.uid;

    try {
      await FirebaseDatabase.instance.ref('users/$userId').set({
        'FirstName': firstname,
        'phonenumber': phone,
        'Email': email,
        'Role': 'User',
      });

      await userCredential.user!.sendEmailVerification();

      final salt = BCrypt.gensalt();
      final hashedPassword = BCrypt.hashpw(password, salt);

      final userData = Users(
        FirstName: firstname,
        phonenumber: phone,
        email: email,
        password: hashedPassword,
        userId: userId,
      );

      await DatabaseHelper().insertUser(userData);
    } catch (e) {
      print('Post-signup step failed: $e');
    }

    return userCredential;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();

    final hasInternet =
        connectivity.contains(ConnectivityResult.wifi) ||
            connectivity.contains(ConnectivityResult.mobile) ||
            connectivity.contains(ConnectivityResult.ethernet);

    if (hasInternet) {
      try {
        final cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = cred.user?.uid;

        if (uid != null) {
          await PrefsService.instance.saveUserId(uid);
        }

        return true;
      } on FirebaseAuthException catch (e) {
        print('Firebase login failed: ${e.code}');
        return false;
      }
    }

    // Offline login
    final localUser = await DatabaseHelper().Loginuser(email, password);

    if (localUser != null) {
      final storedHash = localUser.password;

      final isPasswordValid = BCrypt.checkpw(
        password,
        storedHash,
      );

      if (isPasswordValid) {
        await PrefsService.instance.saveUserId(
          localUser.userId.toString(),
        );

        return true;
      }
    }

    return false;
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


