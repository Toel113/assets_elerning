import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellPage extends StatefulWidget {
  final String nameCourse;

  const SellPage({Key? key, required this.nameCourse}) : super(key: key);

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  late TextEditingController _courseIdController;
  List<QueryDocumentSnapshot>? userDocs;
  bool? newcheck = false;
  final int x = 210;

  @override
  void initState() {
    super.initState();
    _courseIdController = TextEditingController();
  }

  @override
  void dispose() {
    _courseIdController.dispose();
    super.dispose();
  }

  Future<String> getCourseId() async {
    var docRef =
        FirebaseFirestore.instance.collection("Course").doc(widget.nameCourse);
    var docSnapshot = await docRef.get();
    if (docSnapshot.exists && docSnapshot.data()!.containsKey("Course ID")) {
      return docSnapshot.data()!["Course ID"];
    } else {
      return "Course ID not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 109, 109, 109)),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Service',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _buildInfoBox(
                                widget.nameCourse, "Course Name :")),
                        SizedBox(width: 10),
                        Expanded(
                          child: FutureBuilder<String>(
                            future: getCourseId(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildInfoBox(
                                    "Loading...", "Course ID :");
                              } else if (snapshot.hasError) {
                                return _buildInfoBox("Error", "Course ID :");
                              } else {
                                return _buildInfoBox(
                                    snapshot.data!, "Course ID :");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    _buildInfoBox("${x} .-", "Amount :"),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(200, 60),
                        ),
                        child: Text(
                          "Buy Course",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBox(String text, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 185, 185, 185)),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
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
}
