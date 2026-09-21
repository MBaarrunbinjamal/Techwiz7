import 'package:flutter/material.dart';

class chose extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _chose();
  }
}
class _chose extends State<chose>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),

        SizedBox(width: double.infinity,height:30 ,child:ElevatedButton(onPressed: (){
          Navigator.pushReplacementNamed(context, '/register');
        }, child: Text('Register')),),
            const SizedBox(height: 20),
        SizedBox(width: double.infinity,height: 30,child:ElevatedButton(onPressed: (){
          Navigator.pushReplacementNamed(context, "/login");
        }, child: Text('Login')),),
          ],
        ),
      ),
    );
  }
}