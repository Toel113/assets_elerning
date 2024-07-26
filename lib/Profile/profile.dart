import 'dart:io';
import 'package:assets_elerning/Certificate/certificatepage.dart';
import 'package:assets_elerning/payment/historypurches.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
  final String userEmail;

  const ProfilePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _uploadedImageUrl;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  List<QueryDocumentSnapshot>? userDocs;

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.userEmail);
  }

  Future<void> fetchUserData(String userEmail) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot =
          await collectionRef.where('Email', isEqualTo: userEmail).get();

      setState(() {
        userDocs = querySnapshot.docs;
      });

      if (userDocs != null && userDocs!.isNotEmpty) {
        await _fetchImageUrl();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchImageUrl() async {
    try {
      if (userDocs != null && userDocs!.isNotEmpty) {
        var docRef = userDocs!.first.reference;
        DocumentSnapshot doc = await docRef.get();
        if (doc.exists) {
          setState(() {
            _uploadedImageUrl = doc['urlImages'];
          });
        }
      }
    } catch (e) {
      print('Error fetching image URL: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _uploadImage(_imageFile!);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      if (userDocs != null && userDocs!.isNotEmpty) {
        var docRef = userDocs!.first.reference;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${DateTime.now().toIso8601String()}');
        final uploadTask = storageRef.putFile(image);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        await docRef.update({'urlImages': downloadUrl});
        setState(() {
          _uploadedImageUrl = downloadUrl;
        });
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  String obscureEmail(String email) {
    int atIndex = email.indexOf('@');
    if (atIndex <= 1) return email;
    String firstPart = email.substring(0, 3);
    String hiddenPart = '*' * (atIndex - 2);
    String lastPart = email.substring(atIndex - 1);
    return '$firstPart$hiddenPart$lastPart';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.fromARGB(255, 82, 82, 82),
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: _uploadedImageUrl != null
                        ? NetworkImage(_uploadedImageUrl!)
                        : null,
                    child: _uploadedImageUrl == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: getUserData('Fullname'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String fullname = snapshot.data ?? 'No Data';
                        return Text(fullname,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold));
                      }
                    },
                  ),
                  const SizedBox(height: 5),
                  FutureBuilder<String>(
                    future: getUserData('Email'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String email = snapshot.data ?? 'No Data';
                        String obscuredEmail = obscureEmail(email);
                        return Text('Email: $obscuredEmail',
                            style: TextStyle(fontSize: 20));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              BuildEditButton(userEmail: widget.userEmail),
              const SizedBox(height: 20),
              buildButton(context, 'Purchase History',
                  Historypurches(userEmail: widget.userEmail)),
              buildButton(
                context,
                'Certificate',
                FutureBuilder<String>(
                  future: getUserData('Fullname'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return GenerateCertificate(
                        recipientName: snapshot.data ?? '',
                        userEmail: widget.userEmail,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getUserData(String field) async {
    String data = '';
    try {
      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot =
          await collectionRef.where('Email', isEqualTo: widget.userEmail).get();
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first.data();
        data = doc[field] ?? '';
      }
    } catch (e) {
      print("Error: $e");
    }
    return data;
  }

  Widget buildButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 12),
        minimumSize: Size(double.infinity, 40),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class BuildEditButton extends StatefulWidget {
  final String userEmail;

  const BuildEditButton({Key? key, required this.userEmail}) : super(key: key);

  @override
  _BuildEditButtonState createState() => _BuildEditButtonState();
}

class _BuildEditButtonState extends State<BuildEditButton> {
  bool _isExpanded = false;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = fetchUserData(widget.userEmail);
  }

  Future<Map<String, dynamic>> fetchUserData(String userEmail) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot =
          await collectionRef.where('Email', isEqualTo: userEmail).get();
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first.data();
        return doc;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return {};
  }

  Future<void> _updatePassword(String newPassword, String field) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is logged in')),
      );
      return;
    }

    try {
      await user.updatePassword(newPassword);
      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot =
          await collectionRef.where('Email', isEqualTo: widget.userEmail).get();
      if (querySnapshot.docs.isNotEmpty) {
        var docRef = querySnapshot.docs.first.reference;
        await docRef.update({field: newPassword});
        print('Password updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating password: $e')),
      );
    }
  }

  Future<void> _updateUserData(String newValue, String field) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot =
          await collectionRef.where('Email', isEqualTo: widget.userEmail).get();
      if (querySnapshot.docs.isNotEmpty) {
        var docRef = querySnapshot.docs.first.reference;
        await docRef.update({field: newValue});
        print('User data updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No user data found'));
        } else {
          var userData = snapshot.data!;
          fullNameController.text = userData['Fullname'] ?? '';
          phoneNumberController.text = userData['PhoneNumber'] ?? '';
          var userType = userData['TypeEmail'] ?? '';

          return Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                minimumSize: Size(double.infinity, 40),
              ),
              child: Column(
                children: [
                  Text('Edit Profile',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (_isExpanded)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        buildTextField('Fullname', fullNameController,
                            'Fullname', _updateUserData),
                        if (userType == "AppEmail")
                          buildTextField('Password', passwordController,
                              'Password', _updatePassword,
                              obscureText: true),
                        buildTextField('PhoneNumber', phoneNumberController,
                            'PhoneNumber', _updateUserData),
                      ],
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller,
      String field, Function(String, String) updateFunction,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        onSubmitted: (newValue) {
          updateFunction(newValue, field);
        },
      ),
    );
  }
}
