import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techwiz7/Screens/Login.dart';

class emailverification extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return _emailverification();
  }
}
class _emailverification extends State<emailverification>{
    bool isloading=false;
  Future<void>checkverification() async{
    setState(() {
      isloading =true;
    });
    try{
      final user = FirebaseAuth.instance.currentUser;
      if(user==null){
        return;
      }
      await user.reload();
      final updateuser = FirebaseAuth.instance.currentUser;
      if(updateuser!=null && updateuser.emailVerified ){
        if(!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      }
      else{
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email is not verified yet'),
          ),
        );

        print(updateuser?.emailVerified.toString());
        print("You have not verified your email");
      }

    }catch(e){
print('Verification error: $e');
if(!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Error checking email: $e'),
  ),
);
    }finally{
      if(!mounted) {
        setState(() {
          isloading =false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Emailverification'),),
      body: Center(
        child: ElevatedButton(onPressed: isloading ? null:checkverification, child: isloading? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.red,
          ),
        )
        :const Text('I have verified my email'))
      ),
    );
  }
}