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

  Future<List<String>> getDataName(QueryDocumentSnapshot document) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Create PDF File.",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: userDocs?.length ?? 0,
                      itemBuilder: (context, index) {
                        var document = userDocs![index];
                        return FutureBuilder<List<String>>(
                          future: getDataName(document),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text('No completed courses found.');
                            } else {
                              var courses = snapshot.data!;
                              return Column(
                                children: courses.map((course) {
                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(255, 154, 154, 154),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        course,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Name: ${widget.recipientName}",
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                "Date Time: 17-03-2024",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              SizedBox(width: 15),
                                              GestureDetector(
                                                onTap: () async {
                                                  try {
                                                    final certificateFile =
                                                        await CertificatePdfApi
                                                            .generateCertificatePdf(
                                                      widget.recipientName,
                                                      course,
                                                    );
                                                    await SaveAndOpenDocument
                                                        .openPDF(
                                                            certificateFile);
                                                  } catch (e) {
                                                    print(
                                                        'Error generating PDF: $e');
                                                  }
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.description),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      "Create PDF",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
