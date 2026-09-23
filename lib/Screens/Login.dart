import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techwiz7/Services/Firebase_Auth_Services.dart';

class Login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Login();
  }
}
class _Login extends State<Login>{
  late String email;
  late String password;
  final _formkey2 = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        child: Form(
            key: _formkey2,
            child: Container(
              child: Column(children: [
                TextFormField(
                  decoration: InputDecoration(
                      label: Text('Enter your email here')
                  ),
                  validator: (value){
                    if(value==null||value.isEmpty){
                      return "Please enter Your email";
                    }
                    else{
                      email=value;
                    }

                  },
                ),
                const SizedBox(height:20 ,),
                TextFormField(
                  decoration: InputDecoration(
                      label: Text('Enter your password here')
                  ),
                  validator: (value){
                    if(value==null||value.isEmpty){
                      return "Please enter Your password";
                    }
                    else{
                      password=value;
                    }

                  },
                ),
                const SizedBox(height:20 ,),
                ElevatedButton(onPressed: (){
                  if(!_formkey2.currentState!.validate()){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Form should be validated',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );

                    return;
                  }
                  try{
                    AuthService().signIn(email: email, password: password);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Login Sucessfully',
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );

                 Navigator.pushReplacementNamed(context,"/home" );
                  }on FirebaseAuthException catch(e){
                    print(e.code);
                  }
                }, child: Text('Login'))
              ],),
            )),
      ),
    );
  }
}