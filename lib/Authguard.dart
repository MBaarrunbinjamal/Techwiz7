import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:techwiz7/Screens/Login.dart';

class Authguard extends StatelessWidget{
  final Widget child;

  Authguard(this.child);

  @override
  Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser;
if(user==null){
  return Login();
}else{
return child;
}
  }
}