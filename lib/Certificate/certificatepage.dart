import 'package:assets_elerning/Certificate/pdfCertificate.dart';
import 'package:assets_elerning/Certificate/saveandopenpdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GenerateCertificate extends StatefulWidget {
  final String recipientName;
  final String userEmail;
  final String userPassword;

  GenerateCertificate(
      {required this.recipientName,
      required this.userEmail,
      required this.userPassword});

  @override
  _GenerateCertificateState createState() => _GenerateCertificateState();
}

class _GenerateCertificateState extends State<GenerateCertificate> {
  List<QueryDocumentSnapshot>? userDocs;
  bool _isLoading = true;
  String? selectedValue1;

  @override
  void initState() {
    super.initState();
    _fetchUserCourses(widget.userEmail);
  }

  Future<void> _fetchUserCourses(String userEmail) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot =
          await collectionRef.where('Email', isEqualTo: userEmail).get();

      setState(() {
        userDocs = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate PDF')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    title: Center(child: Text("Full Name")),
                    subtitle: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 154, 154, 154),
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Center(
                        child: Text(
                          widget.recipientName,
                          style: TextStyle(fontSize: 25.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Center(child: Text("Select Course")),
                    subtitle: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : userDocs != null
                            ? Column(
                                children: [
                                  Center(
                                    child: CourseDropdownColumn(
                                      documents: userDocs!,
                                      getDataDropdown: getDataDropdown,
                                      onCourseSelected: (value) {
                                        setState(() {
                                          selectedValue1 = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      " *To press the Create PDF button, you must click the dropdown at least once.",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(255, 146, 2, 2),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              )
                            : Center(child: Text('No courses found')),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: selectedValue1 == null
                          ? null
                          : () async {
                              try {
                                final certificateFile = await CertificatePdfApi
                                    .generateCertificatePdf(
                                  widget.recipientName,
                                  selectedValue1!,
                                );
                                await SaveAndOpenDocument.openPDF(
                                    certificateFile);
                              } catch (e) {
                                print('Error generating PDF: $e');
                              }
                            },
                      child: Text(
                        'Create PDF',
                        style: TextStyle(
                          fontSize: 30,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> getDataDropdown(QueryDocumentSnapshot document) async {
    List<String> dataNames = [];

    try {
      var docRef =
          FirebaseFirestore.instance.collection('User').doc(document.id);
      var snapshotData = await docRef.collection('CompleteCourse').get();

      snapshotData.docs.forEach((doc) {
        dataNames.add(doc.id);
      });
    } catch (e, stackTrace) {
      print("Error fetching dropdown data: $e\n$stackTrace");
    }

    return dataNames;
  }
}

class CourseDropdownColumn extends StatefulWidget {
  final List<QueryDocumentSnapshot> documents;
  final Future<List<String>> Function(QueryDocumentSnapshot) getDataDropdown;
  final Function(String) onCourseSelected;

  const CourseDropdownColumn({
    Key? key,
    required this.documents,
    required this.getDataDropdown,
    required this.onCourseSelected,
  }) : super(key: key);

  @override
  _CourseDropdownColumnState createState() => _CourseDropdownColumnState();
}

class _CourseDropdownColumnState extends State<CourseDropdownColumn> {
  String? selectedValue1;
  List<String> items1 = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      List<String> data = await widget.getDataDropdown(widget.documents[0]);
      setState(() {
        items1 = data;
        if (items1.isNotEmpty) {
          selectedValue1 = items1[0];
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching dropdown data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  height: 40,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : items1.isEmpty
                          ? Center(child: Text('No courses found'))
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: DropdownButton<String>(
                                borderRadius: BorderRadius.circular(8),
                                dropdownColor:
                                    Color.fromARGB(255, 219, 219, 219),
                                value: selectedValue1,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedValue1 = newValue;
                                    widget.onCourseSelected(newValue!);
                                  });
                                },
                                items: items1.map((String document) {
                                  return DropdownMenuItem<String>(
                                    value: document,
                                    child: Text(
                                      document,
                                      style: TextStyle(fontSize: 25.0),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                ),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
