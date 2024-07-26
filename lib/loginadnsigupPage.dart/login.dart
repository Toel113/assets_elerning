import 'package:assets_elerning/Course/dashboard.dart';
import 'package:assets_elerning/RegisEmail/userEmail.dart';
import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/singup.dart';
import 'package:assets_elerning/manage/Mainmanage.dart';
import 'package:assets_elerning/model/User.dart';
import 'package:assets_elerning/otp_verification/forget_pass.dart';
import 'package:assets_elerning/theme/theme.dart';
import 'package:assets_elerning/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
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
  Box? box1;

  @override
  void initState() {
    super.initState();
    createBox();
  }

  @override
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
        print("Get Email Success");
      }
      if (box1!.get('pass') != null) {
        pass.text = box1!.get("pass");
        print("Get Password Success");
      }
    }

    setState(() {
      ischeck = true;
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
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
          actions: [
            IconButton(
              icon: Icon(
                Provider.of<ThemeProvider>(context).themeData == ligthmode
                    ? Icons.nightlight_round
                    : Icons.wb_sunny,
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
            ),
          ]),
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
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => sendOTPPageState()),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
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
                            Fluttertoast.showToast(
                              msg: e.message.toString(),
                              gravity: ToastGravity.CENTER,
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          UserCredential userCredential =
                              await signInWithGoogle();

                          User? user = userCredential.user;
                          if (user != null) {
                            String email = user.email!;
                            String uid = user.uid;

                            Fluttertoast.showToast(
                              msg: "Google Sign-In Successful",
                              gravity: ToastGravity.CENTER,
                            );

                            await getData(email, uid, context);
                          }
                        } on FirebaseAuthException catch (e) {
                          Fluttertoast.showToast(
                            msg: e.message.toString(),
                            gravity: ToastGravity.CENTER,
                          );
                        }
                      },
                      child: const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
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
    return Container(
      height: 24.0,
      width: 24.0,
      child: Transform.scale(
        scale: 1.2,
        child: Checkbox(
          value: ischeck,
          onChanged: (value) {
            setState(() {
              ischeck = value!;
            });
          },
          checkColor: Theme.of(context).colorScheme.primary,
          activeColor: Theme.of(context).colorScheme.background,
        ),
      ),
    );
  }

  Future<void> getData(String email, String uid, BuildContext context) async {
    var collection = FirebaseFirestore.instance.collection('User');
    var querySnapshot = await collection.where('Email', isEqualTo: email).get();

    if (querySnapshot.docs.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserGoogleEmailPage(
            userEmail: email,
            userUID: uid,
          ),
        ),
      );
    } else {
      // var document = querySnapshot.docs.first;
      // String emailType = document.data()['EmailType'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            userEmail: email,
            // emailType: emailType,
          ),
        ),
      );
    }
  }
}
