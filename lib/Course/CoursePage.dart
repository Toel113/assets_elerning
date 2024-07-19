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
  StreamSubscription<QuerySnapshot>? _courseStreamSubscription;
  List<QueryDocumentSnapshot>? _allDocs;
  List<QueryDocumentSnapshot>? _filteredDocs;
  List<QueryDocumentSnapshot>? userDocs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchInitialData();
    _fetchUserCourses(widget.userEmail);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _courseStreamSubscription?.cancel();
    super.dispose();
  }

  void _fetchInitialData() {
    _courseStreamSubscription = FirebaseFirestore.instance
        .collection('Course')
        .snapshots()
        .listen((snapshot) {
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

  const FirestoreDataWidget({
    super.key,
    required this.courseDocs,
    required this.userDocs,
    required this.userEmail,
    required this.userPassword,
  });

  Future<String> _fetchField(String documentId) async {
    try {
      var docRef =
          FirebaseFirestore.instance.collection("Course").doc(documentId);
      var docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        if (data != null && data.containsKey('Status')) {
          return data['Status'];
        }
      }
    } catch (e) {
      print('Error fetching field: $e');
    }
    return 'StatusNotFound';
  }

  Future<String> _fetchGetData(String documentId, List<String> nameDocs) async {
    try {
      String firstDocId = nameDocs.isNotEmpty ? nameDocs[0] : '';
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('User')
          .doc(firstDocId)
          .collection('Course')
          .doc(documentId);

      var userDocSnapshot = await userDocRef.get();
      if (userDocSnapshot.exists) {
        var data = userDocSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('StatusGet')) {
          return data['StatusGet'];
        }
      }
    } catch (e) {
      print('Error fetching getData: $e');
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
        DocumentReference userDocRef = FirebaseFirestore.instance
            .collection('User')
            .doc(firstDocId)
            .collection('Course')
            .doc(document.id);

        return GestureDetector(
          onTap: () async {
            try {
              var userDocSnapshot = await userDocRef.get();
              if (userDocSnapshot.exists) {
                var userData = userDocSnapshot.data() as Map<String, dynamic>?;
                if (userData != null && userData.containsKey('Status')) {
                  var statusValue = userData['Status'];
                  var docStatus = await _fetchField(document.id);
                  var StatusGet = await _fetchGetData(document.id, nameDocs);

                  if (statusValue == docStatus &&
                      StatusGet == "Get ${document.id}") {
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
                  } else {
                    if (docStatus == "False") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellPage(
                              UserEmail: userEmail,
                              UserPassword: userPassword,
                              nameCourse: document.id,
                              statusValue: statusValue,
                              dataStatus: docStatus,
                              userDoc: firstDocId,
                              TextButton: "Get Course"),
                        ),
                      );
                    }
                    if (docStatus == "True") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellPage(
                              UserEmail: userEmail,
                              UserPassword: userPassword,
                              nameCourse: document.id,
                              statusValue: statusValue,
                              dataStatus: docStatus,
                              userDoc: firstDocId,
                              TextButton: "Buy Course"),
                        ),
                      );
                    }
                  }
                }
              } else {
                await userDocRef.set({
                  "Status": "False",
                });
                var userData = userDocSnapshot.data() as Map<String, dynamic>?;
                if (userData != null && userData.containsKey('Status')) {
                  var statusValue = userData['Status'];
                  var docStatus = await _fetchField(document.id);
                  var StatusGet = await _fetchGetData(document.id, nameDocs);

                  if (statusValue == docStatus &&
                      StatusGet == "Get ${document.id}") {
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
                  } else {
                    if (docStatus == "False") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellPage(
                              UserEmail: userEmail,
                              UserPassword: userPassword,
                              nameCourse: document.id,
                              statusValue: statusValue,
                              dataStatus: docStatus,
                              userDoc: firstDocId,
                              TextButton: "Get Course"),
                        ),
                      );
                    }
                    if (docStatus == "True") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellPage(
                              UserEmail: userEmail,
                              UserPassword: userPassword,
                              nameCourse: document.id,
                              statusValue: statusValue,
                              dataStatus: docStatus,
                              userDoc: firstDocId,
                              TextButton: "Buy Course"),
                        ),
                      );
                    }
                  }
                }
              }
            } catch (e) {
              print('Error on document tap: $e');
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
