import 'package:assets_elerning/Course/dashboard.dart';
import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/forget_pass.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/singup.dart';
import 'package:assets_elerning/manage/Mainmanage.dart';
import 'package:assets_elerning/model/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screen_protector/screen_protector.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController Email = TextEditingController();
  TextEditingController pass = TextEditingController();
  bool ischeck = false;
  final formkey = GlobalKey<FormState>();
  final profile = Users();
  bool _isObscure = true;
  late Box? box1;

  @override
  @override
  void initState() {
    super.initState();
    createBox();
  }

  void dispose() {
    _disableScreenProtector();
    Email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> createBox() async {
    box1 = await Hive.openBox('logindata');
    getdata();
  }

  void getdata() {
    if (box1 != null && box1!.isOpen) {
      if (box1!.get('email') != null) {
        Email.text = box1!.get("email");
        print("Get Email Succeses");
      }
      if (box1!.get('pass') != null) {
        pass.text = box1!.get("pass");
        print("Get Password Succeses");
      }
    }

    setState(() {
      ischeck = true;
    });
  }

  Future<void> login() async {
    if (box1 != null && box1!.isOpen) {
      if (ischeck) {
        await box1!.put("email", Email.text);
        await box1!.put("pass", pass.text);
        print("Set Data ${Email.text} and ${pass.text} Success");
      }
    } else {
      print("Box not found or not open");
    }
  }

  Future<void> _enableScreenProtector() async {
    await ScreenProtector.preventScreenshotOn();
  }

  Future<void> _disableScreenProtector() async {
    await ScreenProtector.preventScreenshotOff();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: FutureBuilder<String>(
            future: getUrlImages1(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    snapshot.data!,
                    fit: BoxFit.contain,
                  ),
                );
              }
            },
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
            ),
            child: Container(
              width: screenWidth * 0.8,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(255, 155, 154, 154)),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 50,
                        color: Color.fromARGB(255, 29, 29, 29),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextFormField(
                        controller: Email,
                        decoration: const InputDecoration(
                          hintText: 'Enter your Email',
                          labelText: 'Email',
                        ),
                        onSaved: (String? email) {
                          profile.email = email!;
                        },
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: "Please Enter your Email"),
                          EmailValidator(
                              errorText: "Email format is incorrect.")
                        ]),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextFormField(
                            controller: pass,
                            obscureText: _isObscure,
                            decoration: const InputDecoration(
                              hintText: 'Enter your Password',
                              labelText: 'Password',
                            ),
                            onSaved: (String? password) {
                              profile.password = password!;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                            icon: Icon(_isObscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              _buildCheckbox(),
                              const SizedBox(width: 1),
                              const Text(
                                'Remember Me',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PhoneAuth()),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 31, 31, 31),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (formkey.currentState!.validate()) {
                          formkey.currentState?.save();
                          await login();
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: profile.email,
                              password: profile.password,
                            )
                                .then((value) async {
                              formkey.currentState?.reset();
                              final adminSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('Admin')
                                  .where('Email', isEqualTo: profile.email)
                                  .get();
                              final userSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('User')
                                  .where('Email', isEqualTo: profile.email)
                                  .get();

                              if (adminSnapshot.docs.isNotEmpty) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainmanagePage(),
                                  ),
                                );
                              } else if (userSnapshot.docs.isNotEmpty) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardPage(
                                      userEmail: profile.email,
                                      userPassword: profile.password,
                                    ),
                                  ),
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Email or Password incorrect",
                                  gravity: ToastGravity.CENTER,
                                );
                              }
                            });
                          } on FirebaseAuthException catch (e) {
                            String errorMessage = "An error occurred";
                            if (e.code == 'user-not-found') {
                              errorMessage = 'No user found for that email.';
                            } else if (e.code == 'wrong-password') {
                              errorMessage =
                                  'Wrong password provided for that user.';
                            }
                            Fluttertoast.showToast(
                              msg: errorMessage,
                              gravity: ToastGravity.CENTER,
                            );
                          } catch (e) {
                            print('Error: $e');
                            Fluttertoast.showToast(
                              msg: "An error occurred",
                              gravity: ToastGravity.CENTER,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Color.fromARGB(255, 31, 31, 31),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Need an account?',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color.fromARGB(255, 31, 31, 31),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 31, 31, 31),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return StatefulBuilder(builder: (context, setState) {
      return Checkbox(
        value: ischeck,
        onChanged: (newbool) {
          setState(() {
            ischeck = newbool!;
          });
        },
      );
    });
  }
}
