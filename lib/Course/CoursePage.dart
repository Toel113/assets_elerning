import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:assets_elerning/Course/stationPage.dart';
import 'package:assets_elerning/payment/payment_service.dart';

class CoursePage extends StatefulWidget {
  final String userEmail;
  final String userPassword;

  const CoursePage({
    super.key,
    required this.userEmail,
    required this.userPassword,
  });

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> courseDocs = [];
  Stream<QuerySnapshot>? _courseStream;
  List<QueryDocumentSnapshot>? _allDocs;
  List<QueryDocumentSnapshot>? _filteredDocs;
  List<QueryDocumentSnapshot>? userDocs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchInitialData();
    fetchCourses(widget.userEmail);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchInitialData() {
    _courseStream = FirebaseFirestore.instance.collection('Course').snapshots();
    _courseStream!.listen((snapshot) {
      setState(() {
        _allDocs = snapshot.docs;
        _filteredDocs = _allDocs;
      });
    });
  }

  void _onSearchChanged() {
    setState(() {
      String searchQuery = _searchController.text.trim().toLowerCase();
      if (searchQuery.isEmpty) {
        _filteredDocs = _allDocs;
      } else {
        _filteredDocs = _allDocs?.where((doc) {
          return doc.id.toLowerCase().contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> fetchCourses(String userEmail) async {
    var collectionRef = FirebaseFirestore.instance.collection('User');
    var querySnapshot =
        await collectionRef.where('Email', isEqualTo: userEmail).get();

    setState(() {
      userDocs = querySnapshot.docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FirestoreDataWidget(
                          courseDocs: _filteredDocs,
                          userDocs: userDocs,
                          userEmail: widget.userEmail,
                          userPassword: widget.userPassword,
                          Docsfield: '',
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FirestoreDataWidget extends StatelessWidget {
  final List<QueryDocumentSnapshot>? courseDocs;
  final List<QueryDocumentSnapshot>? userDocs;
  final String userEmail;
  final String userPassword;
  final String Docsfield;

  const FirestoreDataWidget({
    super.key,
    required this.courseDocs,
    required this.userDocs,
    required this.userEmail,
    required this.userPassword,
    required this.Docsfield,
  });

  Future<String> fetchField(String documentId) async {
    var docRef =
        FirebaseFirestore.instance.collection("Course").doc(documentId);

    var docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      var data = docSnapshot.data();
      if (data != null && data.containsKey('Status')) {
        return data['Status'];
      }
    }
    return 'StatusNotFound';
  }

  @override
  Widget build(BuildContext context) {
    if (courseDocs == null || userDocs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courseDocs!.isEmpty) {
      return const Center(child: Text('No courses found'));
    }

    return ListView.builder(
      itemCount: courseDocs!.length,
      itemBuilder: (context, index) {
        var document = courseDocs![index];
        var documentName = document.id;
        var imageUrl = document['images'];
        var nameDocs = userDocs!.map((doc) => doc.id).toList();
        String firstDocId = nameDocs.isNotEmpty ? nameDocs[0] : '';
        print(firstDocId);
        DocumentReference userDocRef = FirebaseFirestore.instance
            .collection('User')
            .doc(firstDocId)
            .collection('Course')
            .doc(document.id);
        print(nameDocs);

        return GestureDetector(
          onTap: () async {
            var userDocSnapshot = await userDocRef.get();
            if (userDocSnapshot.exists) {
              var userData = userDocSnapshot.data() as Map<String, dynamic>?;
              if (userData != null && userData.containsKey('Status')) {
                var statusValue = userData['Status'];
                var docStatus = await fetchField(document.id);
                if (statusValue == docStatus) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StationPage(
                        documentId: document.id,
                        UserEmail: userEmail,
                        UserPassword: userPassword,
                      ),
                    ),
                  );
                  print("Document ID : ${document.id}");
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellPage(
                        nameCourse: document.id,
                      ),
                    ),
                  );
                }
              }
            } else {
              print('Document does not exist.');
              await userDocRef.set({
                "Status": "False",
              }).then((_) {
                print("Document created successfully!");
              }).catchError((error) {
                print('Error creating document: $error');
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellPage(
                    nameCourse: document.id,
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return const Center(
                          child: Text(
                            'Could not load image',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  documentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Courses {
  String coursename = '';
  String docname = '';
  String amountCourse = '';
}
