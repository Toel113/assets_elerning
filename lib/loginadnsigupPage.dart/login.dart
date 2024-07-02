// import 'package:assets_elerning/Course/dashboard.dart';
// import 'package:assets_elerning/LoginAndSignup/Repassword.dart';
// import 'package:assets_elerning/LoginAndSignup/signup.dart';
// import 'package:assets_elerning/manage/mainmanage.dart';
// import 'package:assets_elerning/model/User.dart';
import 'package:assets_elerning/Course/dashboard.dart';
import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/singup.dart';
import 'package:assets_elerning/manage/mainmanage.dart';
import 'package:assets_elerning/model/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool? newcheck = false;
  final formkey = GlobalKey<FormState>();
  final Users profile = Users();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
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
                return Image.network(
                  snapshot.data!,
                  fit: BoxFit.contain,
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
                        ]).call,
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
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => Repassword()),
                              // );
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
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: profile.email,
                              password: profile.password,
                            )
                                .then((value) {
                              formkey.currentState?.reset();
                              if (profile.email == "Admin123@gmail.com") {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainmanagePage(),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardPage(
                                      userEmail: profile.email,
                                      userPassword: profile.password,
                                    ),
                                  ),
                                );
                              }
                            });
                          } on FirebaseAuthException catch (e) {
                            Fluttertoast.showToast(
                              msg: e.message ?? "An error occurred",
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
                                  builder: (context) => const SignUpPage()),
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
        value: newcheck,
        onChanged: (newbool) {
          setState(() {
            newcheck = newbool;
          });
        },
      );
    });
  }
}
