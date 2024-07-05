import 'package:assets_elerning/MenuProfile/Add_Chang_Credit_card.dart';
import 'package:assets_elerning/MenuProfile/Address.dart';
import 'package:assets_elerning/MenuProfile/Contant.dart';
import 'package:assets_elerning/MenuProfile/Membership.dart';
import 'package:assets_elerning/MenuProfile/PurchaseHistory.dart';
import 'package:assets_elerning/api/loadImages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_field_validator/form_field_validator.dart';

class NewData {
  String fullname;
  String email;
  String password;
  String phonenumber;

  NewData({
    this.fullname = '',
    this.email = '',
    this.password = '',
    this.phonenumber = '',
  });
}

class ProfilePage extends StatefulWidget {
  final String UserEmail;
  final String UserPassword;

  const ProfilePage({
    super.key,
    required this.UserEmail,
    required this.UserPassword,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final NewData newdata = NewData();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border:
                  Border.all(color: const Color.fromARGB(255, 155, 154, 154)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: ClipOval(
                        child: FutureBuilder<String>(
                          future: getUrlImages1(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future: getDatashowName(widget.UserEmail),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  String fullname = snapshot.data ?? 'No Data';
                                  return Text(
                                    fullname,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 5),
                          FutureBuilder<String>(
                            future: getDataEmail(widget.UserEmail),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  String email = snapshot.data ?? 'No Data';
                                  return Text(
                                    'Email: $email',
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 155, 154, 154)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildEditableField(
                        controller: fullNameController,
                        keyboardType: TextInputType.name,
                        hintText: 'New Full Name',
                        labelText: 'Full Name',
                        fieldData: 'Fullname',
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: "Enter Your New Fullname"),
                        ]),
                      ),
                      buildEditableField(
                        controller: passwordController,
                        keyboardType: TextInputType.text,
                        hintText: 'New Password',
                        labelText: 'Password',
                        fieldData: 'Password',
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: "Enter Your New Password"),
                        ]),
                      ),
                      buildEditableField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        hintText: 'New Phone Number',
                        labelText: 'Phone Number',
                        fieldData: 'PhoneNumber',
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: "Enter Your New PhoneNumber"),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                buildButton(context, 'Membership & Subscriptions',
                    const MembershipPage()),
                buildButton(context, 'Purchase History', const PurchasePage()),
                buildButton(context, 'Add/Change Credit Card',
                    const Add_chang_CreditCard()),
                buildButton(context, 'Address', const Address()),
                buildButton(context, 'Contact', const Contant()),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableField(
      {required TextEditingController controller,
      required String hintText,
      required String labelText,
      required String fieldData,
      required TextInputType keyboardType,
      required MultiValidator validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                labelText: labelText,
              ),
              validator:
                  RequiredValidator(errorText: "Enter your $labelText").call,
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              String newData = controller.text;
              await SetAuthentication(widget.UserEmail, fieldData, newData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Updated $labelText successfully'),
                ),
              );
              // Clear the text field after update
              controller.clear();
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.zero,
        minimumSize: const Size(double.infinity, 40),
      ),
      child: Text(text),
    );
  }

  Future<void> SetAuthentication(
      String userEmail, String fieldData, String newData) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      if (fieldData == "Password") {
        if (user != null) {
          try {
            await user.updatePassword(newData);
            setNewData(userEmail, fieldData, newData);
          } catch (e) {
            print('Failed to update email: $e');
          }
        }
      } else {
        setNewData(userEmail, fieldData, newData);
      }
    } catch (e) {}
  }

  Future<void> setNewData(
      String userEmail, String fieldData, String newData) async {
    try {
      if (!userEmail.contains('@gmail.com')) {
        print('Invalid email format');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (newData.trim().isEmpty) {
        print('Field cannot be empty');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Field cannot be empty'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot =
          await collectionRef.where('Email', isEqualTo: userEmail).get();
      if (querySnapshot.docs.isNotEmpty) {
        var docRef = querySnapshot.docs.first.reference;
        await docRef.update({fieldData: newData});
        print("Data updated successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated $fieldData successfully'),
          ),
        );
      } else {
        print("No document found with the specified email");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No document found with the specified email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Failed to update data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> getDatashowName(String userEmail) async {
    String fullname = '';
    try {
      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot =
          await collectionRef.where('Email', isEqualTo: userEmail).get();
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        var fullnameData = data['Fullname'];
        if (fullnameData is String) {
          fullname = fullnameData;
        }
      }
    } catch (e) {
      print("Error: $e");
    }
    return fullname;
  }

  Future<String> getDataEmail(String userEmail) async {
    String email = '';
    try {
      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot =
          await collectionRef.where('Email', isEqualTo: userEmail).get();
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        var emailData = data['Email'];
        if (emailData is String) {
          email = emailData;
        }
      }
    } catch (e) {
      print("Error: $e");
    }
    return email;
  }
}
