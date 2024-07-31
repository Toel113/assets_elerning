import 'dart:async';
import 'package:assets_elerning/Course/stationPage.dart';
import 'package:assets_elerning/theme/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyCoursePage extends StatefulWidget {
  final String userEmail;

  MyCoursePage({required this.userEmail});

  @override
  _MyCoursePageState createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> {
  List<String> documentNames = [];
  List<QueryDocumentSnapshot>? userDocs;
  List<QueryDocumentSnapshot>? documentCourse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await _fetchUserCourses(widget.userEmail);
      await _fetchDocStatusCheck();
      await _fetchDataCourse();
    } catch (e) {
      print('Error fetching data: $e');
    }
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

  Future<void> _fetchDocStatusCheck() async {
    if (userDocs == null || userDocs!.isEmpty) {
      documentNames = [];
      return;
    }
    try {
      var docRef =
          FirebaseFirestore.instance.collection('User').doc(userDocs!.first.id);
      var snapshotRef = await docRef
          .collection('History')
          .where('StatusCheck', isEqualTo: 'Successfully received the course.')
          .get();

      setState(() {
        documentNames = snapshotRef.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error fetching document status check: $e');
    }
  }

  Future<void> _fetchDataCourse() async {
    if (documentNames.isEmpty) {
      setState(() {
        documentCourse = [];
      });
      return;
    }

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Course')
          .where(FieldPath.documentId, whereIn: documentNames)
          .get();

      setState(() {
        documentCourse = querySnapshot.docs;

      });
    } catch (e) {
      print('Error fetching course data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: Center(
            child: ResponsiveBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "My Course",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : buildContainner(
                              courseDocs: documentCourse,
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
      }),
    );
  }
}

class buildContainner extends StatefulWidget {
  final List<QueryDocumentSnapshot>? courseDocs;
  final List<QueryDocumentSnapshot>? userDocs;
  final String userEmail;

  const buildContainner({
    super.key,
    required this.courseDocs,
    required this.userDocs,
    required this.userEmail,
  });
  @override
  _buildContainner createState() => _buildContainner();
}

class _buildContainner extends State<buildContainner> {
  String? _expandedItemId;

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
      var nameDocs = widget.userDocs!.map((doc) => doc.id).toList();
      if (nameDocs.isNotEmpty) {
        var docRef =
            FirebaseFirestore.instance.collection("User").doc(nameDocs.first);
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

  Widget build(BuildContext context) {
    if (widget.courseDocs == null || widget.userDocs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.courseDocs!.isEmpty) {
      return const Center(child: Text('No courses found'));
    }

    return LayoutBuilder(builder: (context, constraints) {
      // double maxHeight = constraints.maxHeight;
      // double maxWidth = constraints.maxWidth;
      // double containerHeight;
      // if (maxWidth >= 600) {
      //   containerHeight = maxHeight * 0.75;
      // } else {
      //   containerHeight = maxHeight * 0.3;
      // }
      return ListView.builder(
          itemCount: widget.courseDocs!.length,
          itemBuilder: (context, index) {
            var document = widget.courseDocs![index];
            var documentName = document.id;
            // var imageUrl = document['images'];
            var nameDocs = widget.userDocs!.map((doc) => doc.id).toList();
            String firstDocId = nameDocs.isNotEmpty ? nameDocs[0] : '';
            DocumentReference userDocRef = FirebaseFirestore.instance
                .collection('User')
                .doc(firstDocId)
                .collection('Course')
                .doc(documentName);

            return GestureDetector(
              onTap: () async {
                try {
                  var userDocSnapshot = await userDocRef.get();
                  if (userDocSnapshot.exists) {
                    var userData =
                        userDocSnapshot.data() as Map<String, dynamic>?;
                    if (userData != null && userData.containsKey('Status')) {
                      setState(() {
                        _expandedItemId = _expandedItemId == documentName
                            ? null
                            : documentName;
                      });
                      return;
                    }
                  } else {
                    setState(() {
                      _expandedItemId =
                          _expandedItemId == documentName ? null : documentName;
                    });
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
                    // if (imageUrl != null && imageUrl.isNotEmpty)
                    //   Container(
                    //     width: double.infinity,
                    //     height: containerHeight,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //     ),
                    //     child: Image.network(
                    //       imageUrl,
                    //       fit: BoxFit.cover,
                    //       errorBuilder: (context, error, stackTrace) {
                    //         return const Center(
                    //           child: Text(
                    //             'Could not load image',
                    //             style: TextStyle(color: Colors.red),
                    //           ),
                    //         );
                    //       },
                    //     ),
                    //   ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer),
                      child: ListTile(
                        title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                documentName,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).hintColor),
                              ),
                              Spacer(),
                              FutureBuilder<String>(
                                future: _fetchAmount(documentName),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text("",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).hintColor));
                                  } else if (snapshot.hasError) {
                                    return Text("Error",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).hintColor));
                                  } else if (snapshot.hasData &&
                                      snapshot.data != '') {
                                    return Text(" ราคา ${snapshot.data} .-",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).hintColor));
                                  } else {
                                    return Text(" Free",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).hintColor));
                                  }
                                },
                              ),
                            ]),
                        subtitle: _expandedItemId == documentName
                            ? Column(
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
                                          "",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text(
                                          "Error",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        );
                                      } else if (snapshot.hasData &&
                                          snapshot.data != '') {
                                        var data = snapshot.data;
                                        return RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    "รายละเอียด $documentName : ",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                ),
                                              ),
                                              (data != null &&
                                                      data != 'StatusNotFound')
                                                  ? TextSpan(
                                                      text: data,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                      ),
                                                    )
                                                  : TextSpan(
                                                      text: "-",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Theme.of(context)
                                                            .hintColor,
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              var userDocSnapshot =
                                                  await userDocRef.get();
                                              if (userDocSnapshot.exists) {
                                                var userData = userDocSnapshot
                                                        .data()
                                                    as Map<String, dynamic>?;
                                                if (userData != null &&
                                                    userData.containsKey(
                                                        'Status')) {
                                                  var statusValue =
                                                      userData['Status'];
                                                  var docStatus =
                                                      await _fetchField(
                                                          documentName);
                                                  var StatusGet =
                                                      await _fetchGetData(
                                                          documentName,
                                                          nameDocs);

                                                  if (statusValue ==
                                                          docStatus &&
                                                      StatusGet ==
                                                          "Get ${documentName}") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            StationPage(
                                                          documentId:
                                                              documentName,
                                                          UserEmail:
                                                              widget.userEmail,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              } else {
                                                var userData = userDocSnapshot
                                                        .data()
                                                    as Map<String, dynamic>?;
                                                if (userData != null &&
                                                    userData.containsKey(
                                                        'Status')) {
                                                  var statusValue =
                                                      userData['Status'];
                                                  var docStatus =
                                                      await _fetchField(
                                                          documentName);
                                                  var StatusGet =
                                                      await _fetchGetData(
                                                          documentName,
                                                          nameDocs);

                                                  if (statusValue ==
                                                          docStatus &&
                                                      StatusGet ==
                                                          "Get ${documentName}") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            StationPage(
                                                          documentId:
                                                              documentName,
                                                          UserEmail:
                                                              widget.userEmail,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            } catch (e) {
                                              print(
                                                  'Error on document tap: $e');
                                            }
                                          },
                                          child: FutureBuilder<String>(
                                            future: _fetchGetData(
                                                documentName, nameDocs),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Text('');
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                  "Error",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                );
                                              } else if (snapshot.hasData &&
                                                  snapshot.data ==
                                                      'Get $documentName') {
                                                return FutureBuilder<
                                                    DocumentSnapshot>(
                                                  future: userDocRef.get(),
                                                  builder: (context,
                                                      userDocSnapshot) {
                                                    if (userDocSnapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Text('');
                                                    } else if (userDocSnapshot
                                                        .hasError) {
                                                      return Text(
                                                        "Error",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      );
                                                    } else if (userDocSnapshot
                                                            .hasData &&
                                                        userDocSnapshot
                                                            .data!.exists) {
                                                      var userData =
                                                          userDocSnapshot
                                                                  .data!
                                                                  .data()
                                                              as Map<String,
                                                                  dynamic>?;
                                                      if (userData != null &&
                                                          userData.containsKey(
                                                              'Status')) {
                                                        var statusValue =
                                                            userData['Status'];
                                                        return FutureBuilder<
                                                            String>(
                                                          future: _fetchField(
                                                              documentName),
                                                          builder: (context,
                                                              docStatusSnapshot) {
                                                            if (docStatusSnapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return Text('');
                                                            } else if (docStatusSnapshot
                                                                .hasError) {
                                                              return Text(
                                                                "Error",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              );
                                                            } else if (docStatusSnapshot
                                                                .hasData) {
                                                              var docStatus =
                                                                  docStatusSnapshot
                                                                      .data;
                                                              return FutureBuilder<
                                                                  String>(
                                                                future:
                                                                    _fetchGetData(
                                                                        document
                                                                            .id,
                                                                        nameDocs),
                                                                builder: (context,
                                                                    statusGetSnapshot) {
                                                                  if (statusGetSnapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    return Text(
                                                                        '');
                                                                  } else if (statusGetSnapshot
                                                                      .hasError) {
                                                                    return Text(
                                                                      "Error",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    );
                                                                  } else if (statusGetSnapshot
                                                                      .hasData) {
                                                                    var statusGet =
                                                                        statusGetSnapshot
                                                                            .data;
                                                                    if (statusValue ==
                                                                            docStatus &&
                                                                        statusGet ==
                                                                            "Get ${documentName}") {
                                                                      return Text(
                                                                        "Start",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      return Text(
                                                                        "Waiting...",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      );
                                                                    }
                                                                  } else {
                                                                    return Text(
                                                                        '');
                                                                  }
                                                                },
                                                              );
                                                            } else {
                                                              return Text('');
                                                            }
                                                          },
                                                        );
                                                      } else {
                                                        return Text(
                                                          "No Status",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor,
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      return Text('');
                                                    }
                                                  },
                                                );
                                              } else {
                                                return Text(
                                                  "Get",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      FutureBuilder<String>(
                                        future: _fetchPersence(documentName),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text("",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .hintColor));
                                          } else if (snapshot.hasError) {
                                            return Text("Error",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .hintColor));
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
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : null,
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    });
  }
}
