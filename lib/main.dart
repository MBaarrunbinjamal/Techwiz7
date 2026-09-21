import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techwiz7/Authguard.dart';
import 'package:techwiz7/Screens/Home.dart';
import 'package:techwiz7/Screens/Login.dart';
import 'package:techwiz7/Screens/Register.dart';
import 'package:techwiz7/Screens/Spalsh.dart';
import 'package:techwiz7/Screens/chose.dart';
import 'package:techwiz7/Screens/emailverification.dart';
import 'package:techwiz7/Services/permisions_service.dart';
import 'package:techwiz7/firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://rxuxpdeuancbjupzehse.supabase.co',
    anonKey: 'sb_publishable__QzP_6XKXzcG9Euteo4-xA_EneQZFF9',
  );
permisions().getnotificationpermision();
  runApp(MaterialApp(

    debugShowCheckedModeBanner: false,
    home: Splash(),
    routes: {
      '/home':(context)=> Authguard(Home()),
      '/chose':(context)=> chose(),
      '/register':(context)=> Register(),
      '/login':(context)=> Login(),
      '/email':(context)=> emailverification(),
    },
  ));
}

