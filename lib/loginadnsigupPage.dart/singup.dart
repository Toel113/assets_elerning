import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/model/User.dart';
import 'package:assets_elerning/theme/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

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
      await firestore.collection("User").doc().set({
        "Fullname": profile.fullname,
        "Email": profile.email,
        "Password": profile.password,
        "Status": "User"
      });
      print(
          "Add Data Success ${profile.fullname} , ${profile.email}, ${profile.password}");
    } catch (e) {
      print("Error Add data fail $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: ResponsiveContainer(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 155, 154, 154)),
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
                          RequiredValidator(errorText: "Please Enter your Email"),
                          EmailValidator(errorText: "Enter a valid email address")
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
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildCheckbox(context),
                                const SizedBox(width: 5.0),
                                const Expanded(
                                  child: Text(
                                    'Confirm registration.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),

                      buildButton(context),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
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
                                      builder: (context) => LoginPage()));
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
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
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (formkey.currentState!.validate()) {
                        formkey.currentState?.save();

                        // Check if email is already in use
                        bool emailInUse =
                            await isEmailAlreadyInUse(profile.email);
                        if (emailInUse) {
                          Fluttertoast.showToast(
                              msg: "Email already in use",
                              gravity: ToastGravity.CENTER);
                          return;
                        }

                        // Add user to Firestore
                        await AddUsertofirestore();

                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: profile.email,
                                  password: profile.password);
                          Fluttertoast.showToast(
                              msg: "Sign Up Successful",
                              gravity: ToastGravity.CENTER);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        } on FirebaseAuthException catch (e) {
                          Fluttertoast.showToast(
                              msg: e.message ?? "",
                              gravity: ToastGravity.CENTER);
                        }
                      }
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
        // padding: const EdgeInsets.fromLTRB(60.0, 30.0, 60.0, 30.0),
      ),
      child: const Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 25.0,
        ),
      ),
    );
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

  Future<bool> isEmailAlreadyInUse(String email) async {
    try {
      // ignore: deprecated_member_use
      final signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      print("Error checking email existence: $e");
      return false;
    }
  }
}
