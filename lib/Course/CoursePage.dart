import 'package:assets_elerning/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:assets_elerning/Course/stationPage.dart';
import 'package:assets_elerning/payment/payment_service.dart';

class CoursePage extends StatefulWidget {
  final String userEmail;

  const CoursePage({
    super.key,
    required this.userEmail,
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

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchUserCourses(widget.userEmail);
    _fetchInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
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
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Center(
              child: ResponsiveBox(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : FirestoreDataPage(
                                courseDocs: _filteredDocs,
                                userDocs: userDocs,
                                userEmail: widget.userEmail,
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
}

class FirestoreDataPage extends StatefulWidget {
  final List<QueryDocumentSnapshot>? courseDocs;
  final List<QueryDocumentSnapshot>? userDocs;
  final String userEmail;

  const FirestoreDataPage({
    super.key,
    required this.courseDocs,
    required this.userDocs,
    required this.userEmail,
  });
  @override
  _FirestoreDataWidget createState() => _FirestoreDataWidget();
}

class _FirestoreDataWidget extends State<FirestoreDataPage> {
  Map<String, bool> _expandedState = {};

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

  Future<String> _fetchAmount(String documentId) async {
    try {
      var docRef =
          FirebaseFirestore.instance.collection("Course").doc(documentId);
      var docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        if (data != null && data.containsKey('Amount')) {
          return data['Amount'];
        }
      }
    } catch (e) {
      print('Error fetching field: $e');
    }
    return 'StatusNotFound';
  }

  Future<String> _fetchDetail(String documentId) async {
    try {
      var docRef =
          FirebaseFirestore.instance.collection("Course").doc(documentId);
      var docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        if (data != null && data.containsKey('Detail')) {
          return data['Detail'];
        }
      }
    } catch (e) {
      print('Error fetching field: $e');
    }
    return 'StatusNotFound';
  }

  Future<String> _fetchPersence(String documentId) async {
    try {
      // Assuming you want to use the first document ID from the userDocs list
      var nameDocs = widget.userDocs!.map((doc) => doc.id).toList();
      if (nameDocs.isNotEmpty) {
        var docRef = FirebaseFirestore.instance
            .collection("User")
            .doc(nameDocs.first); // Use the first document ID
        var subcollRef = docRef.collection('Course').doc(documentId);
        var docSnapshot = await subcollRef.get();
        if (docSnapshot.exists) {
          var data = docSnapshot.data();
          if (data != null && data.containsKey('Complete $documentId')) {
            return data['Complete $documentId'];
          }
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
    if (widget.courseDocs == null || widget.userDocs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.courseDocs!.isEmpty) {
      return const Center(child: Text('No courses found'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double maxHeight = constraints.maxHeight;
        double maxWidth = constraints.maxWidth;
        double containerHeight;
        if (maxWidth >= 600) {
          containerHeight = maxHeight * 0.75;
        } else {
          containerHeight = maxHeight * 0.3;
        }
        return ListView.builder(
          itemCount: widget.courseDocs!.length,
          itemBuilder: (context, index) {
            var document = widget.courseDocs![index];
            var documentName = document.id;
            var imageUrl = document['images'];
            var nameDocs = widget.userDocs!.map((doc) => doc.id).toList();
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
                    var userData =
                        userDocSnapshot.data() as Map<String, dynamic>?;
                    if (userData != null && userData.containsKey('Status')) {
                      setState(() {
                        _expandedState[documentName] =
                            !_expandedState.containsKey(documentName) ||
                                !_expandedState[documentName]!;
                      });
                      return;
                    } else {
                      await userDocRef.set({
                        "Status": "False",
                      });
                      setState(() {
                        _expandedState[documentName] =
                            !_expandedState.containsKey(documentName) ||
                                !_expandedState[documentName]!;
                      });
                    }
                  }
                } catch (e) {
                  print('Error updating document: $e');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Theme.of(context).colorScheme.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: containerHeight,
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
                    if (_expandedState[documentName] == true)
                      ListTile(
                        title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                documentName,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                              Spacer(),
                              FutureBuilder<String>(
                                future: _fetchAmount(documentName),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text("Loading...",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background));
                                  } else if (snapshot.hasError) {
                                    return Text("Error",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background));
                                  } else if (snapshot.hasData &&
                                      snapshot.data != '') {
                                    return Text(" ราคา ${snapshot.data} .-",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background));
                                  } else {
                                    return Text(" Free",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background));
                                  }
                                },
                              ),
                            ]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<String>(
                              future: _fetchDetail(documentName),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    "Loading...",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    "Error",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                    ),
                                  );
                                } else if (snapshot.hasData &&
                                    snapshot.data != '') {
                                  var data = snapshot.data;
                                  return RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "รายละเอียด $documentName : ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background,
                                          ),
                                        ),
                                        (data != null &&
                                                data != 'StatusNotFound')
                                            ? TextSpan(
                                                text: data,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .background,
                                                ),
                                              )
                                            : TextSpan(
                                                text: "-",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .background,
                                                ),
                                              )
                                      ],
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          var userDocSnapshot =
                                              await userDocRef.get();
                                          if (userDocSnapshot.exists) {
                                            var userData =
                                                userDocSnapshot.data()
                                                    as Map<String, dynamic>?;
                                            if (userData != null &&
                                                userData
                                                    .containsKey('Status')) {
                                              var statusValue =
                                                  userData['Status'];
                                              var docStatus = await _fetchField(
                                                  document.id);
                                              var StatusGet =
                                                  await _fetchGetData(
                                                      document.id, nameDocs);

                                              if (statusValue == docStatus &&
                                                  StatusGet ==
                                                      "Get ${document.id}") {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StationPage(
                                                      documentId: document.id,
                                                      UserEmail:
                                                          widget.userEmail,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                if (docStatus == "False") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SellPage(
                                                              UserEmail: widget
                                                                  .userEmail,
                                                              nameCourse:
                                                                  document.id,
                                                              statusValue:
                                                                  statusValue,
                                                              dataStatus:
                                                                  docStatus,
                                                              userDoc:
                                                                  firstDocId,
                                                              TextButton:
                                                                  "Get Course"),
                                                    ),
                                                  );
                                                }
                                                if (docStatus == "True") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SellPage(
                                                              UserEmail: widget
                                                                  .userEmail,
                                                              nameCourse:
                                                                  document.id,
                                                              statusValue:
                                                                  statusValue,
                                                              dataStatus:
                                                                  docStatus,
                                                              userDoc:
                                                                  firstDocId,
                                                              TextButton:
                                                                  "Buy Course"),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          } else {
                                            var userData =
                                                userDocSnapshot.data()
                                                    as Map<String, dynamic>?;
                                            if (userData != null &&
                                                userData
                                                    .containsKey('Status')) {
                                              var statusValue =
                                                  userData['Status'];
                                              var docStatus = await _fetchField(
                                                  document.id);
                                              var StatusGet =
                                                  await _fetchGetData(
                                                      document.id, nameDocs);

                                              if (statusValue == docStatus &&
                                                  StatusGet ==
                                                      "Get ${document.id}") {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StationPage(
                                                      documentId: document.id,
                                                      UserEmail:
                                                          widget.userEmail,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                if (docStatus == "False") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SellPage(
                                                              UserEmail: widget
                                                                  .userEmail,
                                                              nameCourse:
                                                                  document.id,
                                                              statusValue:
                                                                  statusValue,
                                                              dataStatus:
                                                                  docStatus,
                                                              userDoc:
                                                                  firstDocId,
                                                              TextButton:
                                                                  "Get Course"),
                                                    ),
                                                  );
                                                }
                                                if (docStatus == "True") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SellPage(
                                                              UserEmail: widget
                                                                  .userEmail,
                                                              nameCourse:
                                                                  document.id,
                                                              statusValue:
                                                                  statusValue,
                                                              dataStatus:
                                                                  docStatus,
                                                              userDoc:
                                                                  firstDocId,
                                                              TextButton:
                                                                  "Buy Course"),
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
                                      child: const Text('Start.')),
                                ),
                                Spacer(),
                                FutureBuilder<String>(
                                  future: _fetchPersence(documentName),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading...",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .background));
                                    } else if (snapshot.hasError) {
                                      return Text("Error",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .background));
                                    } else {
                                      final data = snapshot.data;
                                      return Text(
                                        (data != null &&
                                                data != 'StatusNotFound')
                                            ? "Progress: $data"
                                            : "Progress: 0%",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
