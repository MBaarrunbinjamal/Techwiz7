import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Splash extends StatefulWidget{
  @override

  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Splash();
  }
  
}
class _Splash extends State<Splash>{
  @override

  void initState() {
    super.initState();
    // TODO: implement initState
navigatetohme();
  }
  void navigatetohme() {
    final user = FirebaseAuth.instance.currentUser;
   Timer(const Duration(seconds: 5),(){
     if(user!=null){
       Navigator.pushReplacementNamed(context, '/home');
     }else{
       Navigator.pushReplacementNamed(context, '/chose');
     }
      ;
   });

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     body: Center(
       child: Text("Splash Screen Techwiz7"),
     ),
   );
  }
}