import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz7/Screens/Login.dart';
import 'package:techwiz7/Screens/emailverification.dart';

/// Shows [child] only for signed-in users with a verified email.
class Authguard extends StatelessWidget {
  final Widget child;

  const Authguard(this.child, {super.key});

  Future<User?> _getFreshUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      await user.reload();
    } catch (_) {}
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getFreshUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const Login();
        }
        if (!user.emailVerified) {
          return const emailverification();
        }
        return child;
      },
    );
  }
}