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
      appBar: AppBar(
        title: Center(child: Text('User Profile')),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                buildTextFormField(
                    hintText: 'Enter your Full Name',
                    labelText: 'Full Name',
                    onSaved: (String? fullname) {
                      user.fullname = fullname!;
                    },
                    validator: RequiredValidator(
                      errorText: "Please enter your Full Name",
                    ).call,
                    note: "Please enter your full name."),
                SizedBox(height: 16),
                buildTextFormField(
                    hintText: 'Enter your Phone Number',
                    labelText: 'Phone Number',
                    onSaved: (String? phonenumber) {
                      user.phonenumber = phonenumber!;
                    },
                    keyboardType: TextInputType.phone,
                    validator: RequiredValidator(
                      errorText: "Please enter your Phone Number",
                    ).call,
                    note: "Please enter your phone number."),
                SizedBox(height: 20),
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
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16),
                  ),
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
    required String note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onSaved: onSaved,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
        ),
        SizedBox(
          height: 10,
        ),
        Text('* $note')
      ],
    );
  }
}
