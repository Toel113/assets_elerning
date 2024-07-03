import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assets_elerning/model/User.dart';
import 'package:assets_elerning/api/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool? newcheck = false;
  final formkey = GlobalKey<FormState>();
  final Users profile = Users();

  Future<void> AddUsertofirestore() async {
    try {
      await firestore.collection("User").doc(profile.fullname).set({
        "Fullname": profile.fullname,
        "Email": profile.email,
        "Password": profile.password,
      });
      print(
          "Add Data Success ${profile.fullname} , ${profile.email}, ${profile.password}");
    } catch (e) {
      print("Error Add data fail $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
        future: initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: Center(
                child: Text('${snapshot.error}'),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 240, 187, 233),
                automaticallyImplyLeading: false,
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
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
                  child: Container(
                    width: screenWidth * 0.8,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 155, 154, 154)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 70,
                              color: Color.fromARGB(255, 29, 29, 29),
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildTextFormField(
                            hintText: 'Enter your FullName',
                            labelText: 'FullName',
                            onSaved: (String? fullname) {
                              profile.fullname = fullname!;
                            },
                            validator: RequiredValidator(
                                    errorText: "Please Enter your FullName")
                                .call,
                          ),
                          const SizedBox(height: 10.0),
                          buildTextFormField(
                            hintText: 'Enter your Email',
                            labelText: 'Email',
                            onSaved: (String? email) {
                              profile.email = email!;
                            },
                            keyboardType: TextInputType.emailAddress,
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: "Please Enter your Email"),
                              EmailValidator(
                                  errorText: "Enter a valid email address")
                            ]).call,
                          ),
                          const SizedBox(height: 10.0),
                          buildTextFormField(
                            hintText: 'Enter your Password',
                            labelText: 'Password',
                            onSaved: (String? password) {
                              profile.password = password!;
                            },
                            obscureText: true,
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: "Please Enter your Password"),
                              MinLengthValidator(6,
                                  errorText:
                                      "Password must be at least 6 digits long")
                            ]).call,
                          ),
                          const SizedBox(height: 10.0),
                          buildTextFormField(
                            hintText: 'Enter your Phone Number',
                            labelText: 'Phone Number',
                            onSaved: (String? phonenumber) {
                              profile.phonenumber = phonenumber!;
                            },
                            validator: RequiredValidator(
                                    errorText: "Please Enter your Phone Number")
                                .call,
                          ),
                          const SizedBox(height: 10.0),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    buildCheckbox(context),
                                    const SizedBox(width: 5.0),
                                    const Expanded(
                                      child: Text(
                                        'Yes, asset-elearning can email me with promotions and news. (optional)',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              buildTermsAndConditions(),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          buildButton(context),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
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
                                          builder: (context) => LoginPage()));
                                },
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 31, 31, 31),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        });
  }

  Widget buildTextFormField({
    required String hintText,
    required String labelText,
    required FormFieldSetter<String> onSaved,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
        ),
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  Widget buildCheckbox(BuildContext context) {
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

  Widget buildTermsAndConditions() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "By signing up, I agree to asset-elearning's",
          style: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          "Terms of Use & Privacy Policy, and the",
          style: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          "Terms of Use & Privacy Policy of the",
          style: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          "learning platform.",
          style: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget buildButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (newcheck == true) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirmation"),
                content: const Text("Are you sure you want to sign up?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (formkey.currentState!.validate()) {
                        formkey.currentState?.save();
                        AddUsertofirestore();
                        try {
                          FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: profile.email, password: profile.password);
                          formkey.currentState?.reset();
                          Fluttertoast.showToast(
                              msg: "Sign Up Successful",
                              gravity: ToastGravity.CENTER);
                        } on FirebaseAuthException catch (e) {
                          Fluttertoast.showToast(
                              msg: e.message ?? "",
                              gravity: ToastGravity.CENTER);
                        }
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.fromLTRB(60.0, 30.0, 60.0, 30.0),
      ),
      child: const Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 25.0,
          color: Color.fromARGB(255, 31, 31, 31),
        ),
      ),
    );
  }
}
