import 'dart:io';
import 'package:assets_elerning/Certificate/downloadpw.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 154, 154, 154)),
                borderRadius: BorderRadius.circular(5.0),
              ),
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
                            ? Center(
                                child: CourseDropdownColumn(
                                  documents: userDocs!,
                                  getDataDropdown: getDataDropdown,
                                  onCourseSelected: (value) {
                                    setState(() {
                                      selectedValue1 = value;
                                    });
                                  },
                                ),
                              )
                            : Center(child: Text('No courses found')),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: selectedValue1 == null
                          ? null
                          : () async {
                              final pdf = pw.Document();
                              pdf.addPage(
                                pw.Page(
                                  build: (pw.Context context) => pw.Container(
                                    padding: pw.EdgeInsets.all(30),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: PdfColors.black,
                                        width: 3,
                                      ),
                                    ),
                                    child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.center,
                                      children: [
                                        pw.Text(
                                          'Certificate of Completion',
                                          style: pw.TextStyle(
                                            fontSize: 30,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.SizedBox(height: 20),
                                        pw.Text(
                                          'This is to certify that',
                                          style: pw.TextStyle(fontSize: 24),
                                        ),
                                        pw.SizedBox(height: 10),
                                        pw.Text(
                                          widget.recipientName,
                                          style: pw.TextStyle(
                                            fontSize: 36,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.SizedBox(height: 10),
                                        pw.Text(
                                          'has successfully completed the course:',
                                          style: pw.TextStyle(fontSize: 24),
                                        ),
                                        pw.SizedBox(height: 10),
                                        pw.Text(
                                          selectedValue1!,
                                          style: pw.TextStyle(
                                            fontSize: 28,
                                            fontStyle: pw.FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              Directory tempDir = await getTemporaryDirectory();
                              String tempPath = tempDir.path;
                              File file = File('$tempPath/example.pdf');
                              await file.writeAsBytes(await pdf.save());

                              String url = Uri.dataFromBytes(await file.readAsBytes(),mimeType: 'application/pdf').toString();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerScreen(file: file,
                                  fileURL : url),
                                ),
                              );
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
    );
  }
}
