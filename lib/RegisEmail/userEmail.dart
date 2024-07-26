import 'package:assets_elerning/Course/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class UsersEmail {
  String? fullname;
  String? phonenumber;

  UsersEmail({this.fullname, this.phonenumber});
}

class UserGoogleEmailPage extends StatefulWidget {
  final String userEmail;
  final String userUID;

  UserGoogleEmailPage({required this.userEmail, required this.userUID});

  @override
  _UserGoogleEmailPageState createState() => _UserGoogleEmailPageState();
}

class _UserGoogleEmailPageState extends State<UserGoogleEmailPage> {
  UsersEmail user = UsersEmail();
  final formkey = GlobalKey<FormState>();

  Future<void> setDataGoogleEmail() async {
    print('UserUID: ${widget.userUID}');
    print('Email: ${widget.userEmail}');
    print('Fullname: ${user.fullname}');
    print('Phonenumber: ${user.phonenumber}');

    if (widget.userUID.isEmpty) {
      throw ArgumentError('UserUID cannot be empty');
    }

    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userUID)
        .set({
      'Email': widget.userEmail,
      'TypeEmail': 'GoogleEmail',
      'Fullname': user.fullname,
      'Phonenumber': user.phonenumber
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 154, 154, 154)),
              borderRadius: BorderRadius.circular(10)),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add Profile Data."),
                SizedBox(
                  height: 20,
                ),
                buildTextFormField(
                  hintText: 'Enter your FullName',
                  labelText: 'FullName',
                  onSaved: (String? fullname) {
                    user.fullname = fullname!;
                  },
                  validator:
                      RequiredValidator(errorText: "Please Enter your FullName")
                          .call,
                ),
                SizedBox(
                  height: 10,
                ),
                buildTextFormField(
                  hintText: 'Enter your Phone Number',
                  labelText: 'Phone Number',
                  onSaved: (String? phonenumber) {
                    user.phonenumber = phonenumber!;
                  },
                  keyboardType: TextInputType.phone,
                  validator: RequiredValidator(
                          errorText: "Please Enter your Phone Number")
                      .call,
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formkey.currentState?.validate() ?? false) {
                      formkey.currentState?.save();
                      setDataGoogleEmail();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardPage(
                            userEmail: widget.userEmail,
                            
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Set Data'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField({
    required String hintText,
    required String labelText,
    required FormFieldSetter<String?> onSaved,
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
}
