  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:techwiz7/Services/Firebase_Auth_Services.dart';

  class Register extends StatefulWidget{

    @override
    State<StatefulWidget> createState() {
      // TODO: implement createState
      return _Register();
    }
  }
  class _Register extends State<Register>{
   late String firstname ;
   late String lastname ;
   late String email;
    late String password;
    late String confirmpassword;

    final _formkey= GlobalKey<FormState>();
    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return Scaffold(
        appBar: AppBar(
          title: Text('Register'),
        ),
        body: Container(
          child: Form(key:_formkey,
              child: Container(
                child:Container(
                  child:  Column(
                    children: [
                      TextFormField(

                        decoration: InputDecoration(label: Text('Enter Your Firstname here')),
                        validator: (value){
                          if(value == null||value.isEmpty){
                            return 'Please enter your Firstname';
                          }
                          else{
                            firstname=value;
                          }
                        },
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(

                        decoration: InputDecoration(label: Text('Enter Your Lastname here')),
                        validator: (value){
                          if(value == null||value.isEmpty){
                            return 'Please enter your Lastname';
                          }
                          else{
                            lastname=value;
                          }
                        },
                      ),
                      const SizedBox(height:20 ,),
                      TextFormField(

                        decoration: InputDecoration(label: Text('Enter Your Email here')),
                        validator: (value){
                          if(value == null||value.isEmpty){
                            return 'Please enter your Email';
                          }
                          else{
                            email=value;
                          }
                        },
                      ),
                      const SizedBox(height:20 ,),
                      TextFormField(

                        decoration: InputDecoration(label: Text('Enter Your Password here')),
                        validator: (value){
                          if(value == null||value.isEmpty){
                            return 'Please enter your Password';
                          }
                          else{
                            password=value;
                          }
                        },
                      ),
                      const SizedBox(height:20 ,),
                      TextFormField(
                        // controller: confirmpasswordController,
                        decoration: InputDecoration(label: Text('Enter Your Confirm password here')),
                        validator: (value){
                          if(value == null||value.isEmpty){
                            return 'Please enter your Confirm password';
                          }
                          else{
                            confirmpassword=value;
                          }
                        },
                      ),
                      const SizedBox(height:20 ,),
                      ElevatedButton(onPressed: ()async{

                        if(!_formkey.currentState!.validate()){
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
                        if(password!=confirmpassword){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password and confirm password should be the same',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );

                          return;
                        }
                        try{
                          await  AuthService().signUp(email: email, password: password, firstname: firstname, lastname: lastname);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Registered Sucessfully',
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );


                          Navigator.pushReplacementNamed(context, '/email');
                        }on FirebaseAuthException catch(e){
                          print(e.code);
                        }

                      }, child: Text('Register'))
                    ],
                  ),
                )
              )),
        ),
      );
    }
  }