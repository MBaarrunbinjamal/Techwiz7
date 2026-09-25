import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:techwiz7/Screens/Login.dart';

/// Shows [child] when a user is signed in, otherwise the Login screen.
class Authguard extends StatelessWidget {
  final Widget child;

  const Authguard(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Login();
    }
    return child;
  }
}
