import 'package:assets_elerning/Course/dashboard.dart';
import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class SellPage extends StatefulWidget {
  final String nameCourse;
  final String statusValue;
  final String dataStatus;
  final String userDoc;
  final String UserEmail;
  final String UserPassword;
  final String TextButton;

  const SellPage({
    Key? key,
    required this.nameCourse,
    required this.statusValue,
    required this.dataStatus,
    required this.userDoc,
    required this.UserEmail,
    required this.UserPassword,
    required this.TextButton,
  }) : super(key: key);

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  late TextEditingController _courseIdController;
  List<QueryDocumentSnapshot>? userDocs;
  bool? newcheck = false;
  late DateTime date;
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(date);
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

  Future<String> getAmount() async {
    var docRef =
        FirebaseFirestore.instance.collection("Course").doc(widget.nameCourse);
    var docSnapshot = await docRef.get();
    if (docSnapshot.exists && docSnapshot.data()!.containsKey("Amount")) {
      return docSnapshot.data()!["Amount"];
    } else {
      return "Amount not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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
          return SingleChildScrollView(
            child: Padding(
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
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      isLandscape
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                        return _buildInfoBox(
                                            "Error", "Course ID :");
                                      } else {
                                        return _buildInfoBox(
                                            snapshot.data!, "Course ID :");
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildInfoBox(
                                    widget.nameCourse, "Course Name :"),
                                SizedBox(height: 10),
                                FutureBuilder<String>(
                                  future: getCourseId(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _buildInfoBox(
                                          "Loading...", "Course ID :");
                                    } else if (snapshot.hasError) {
                                      return _buildInfoBox(
                                          "Error", "Course ID :");
                                    } else {
                                      return _buildInfoBox(
                                          snapshot.data!, "Course ID :");
                                    }
                                  },
                                ),
                              ],
                            ),
                      SizedBox(height: 20),
                      FutureBuilder<String>(
                        future: getAmount(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != "") {
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: QrImageView(
                                  data: snapshot.data!,
                                  version: QrVersions.auto,
                                  size: constraints.maxWidth * 0.6,
                                ),
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      FutureBuilder<String>(
                        future: getAmount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildInfoBox("Loading...", "Amount :");
                          } else if (snapshot.hasError) {
                            return _buildInfoBox("Error", "Amount :");
                          } else {
                            return _buildInfoBox(
                                "${snapshot.data!} .-", "Amount :");
                          }
                        },
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (widget.statusValue == widget.dataStatus) {
                              upDateGetData();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardPage(
                                      userEmail: widget.UserEmail,
                                      userPassword: widget.UserPassword,
                                    ),
                                  ));
                            } else {
                              upDateGetData();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardPage(
                                      userEmail: widget.UserEmail,
                                      userPassword: widget.UserPassword,
                                    ),
                                  ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 60),
                          ),
                          child: Text(
                            widget.TextButton,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
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

  Future<void> upDateGetData() async {
    DocumentReference userGetCourse = FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userDoc)
        .collection('Course')
        .doc(widget.nameCourse);

    DocumentReference userGetHistory = FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userDoc)
        .collection('History')
        .doc(widget.nameCourse);

    String amount = await getAmount();
    String courseId = await getCourseId();
    if (amount == "") {
      userGetHistory.set({
        "CourseName": widget.nameCourse,
        "Amount": "-",
        "Course ID": courseId,
        "StatusGet": "Get ${widget.nameCourse}",
        "DateTime": formattedDate,
        "StatusCheck": "Successfully received the course."
      });
    } else {
      userGetHistory.set({
        "CourseName": widget.nameCourse,
        "Amount": amount,
        "Course ID": courseId,
        "StatusGet": "Get ${widget.nameCourse}",
        "DateTime": formattedDate,
        "StatusCheck": "Waiting for Admin to check status."
      });
    }

    userGetCourse.update(
        {"StatusGet": "Get ${widget.nameCourse}", "DateTime": formattedDate});
  }
}
