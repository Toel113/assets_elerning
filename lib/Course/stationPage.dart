import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/Course/dashboard.dart';
import 'package:assets_elerning/Station/FirstPage.dart';

class StationPage extends StatefulWidget {
  final String documentId;
  final String UserEmail;

  const StationPage({
    Key? key,
    required this.documentId,
    required this.UserEmail,
  }) : super(key: key);

  @override
  _StationPageState createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  List<QueryDocumentSnapshot>? userDocs;

  @override
  void initState() {
    super.initState();
    fetchCourses(widget.UserEmail);
  }

  Future<void> fetchCourses(String userEmail) async {
    var collectionRef = FirebaseFirestore.instance.collection('User');
    var querySnapshot =
        await collectionRef.where('Email', isEqualTo: userEmail).get();

    setState(() {
      userDocs = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(
                  userEmail: widget.UserEmail,
                ),
              ),
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
                return Image.network(
                  snapshot.data!,
                  fit: BoxFit.contain,
                );
              }
            },
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FirestoreDataWidget(
                    userDocs: userDocs,
                    documentId: widget.documentId,
                    userEmail: widget.UserEmail,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FirestoreDataWidget extends StatelessWidget {
  final List<QueryDocumentSnapshot>? userDocs;
  final String documentId;
  final String userEmail;

  const FirestoreDataWidget({
    Key? key,
    required this.userDocs,
    required this.documentId,
    required this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getSubcollectionNames(documentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No subcollections found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var subcollectionName = snapshot.data![index];

            return SubcollectionDropdown(
              documentId: documentId,
              subcollectionName: subcollectionName,
              userEmail: userEmail,
            );
          },
        );
      },
    );
  }

  Future<List<String>> getSubcollectionNames(String documentId) async {
    List<String> subcollectionNames = [];

    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('NameStation')
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();
        var fieldNames = data?.keys.toList();

        for (var fieldName in fieldNames!) {
          var fieldValue = data?[fieldName];
          print('DatafieldName: $fieldValue');

          var subcollectionRef = FirebaseFirestore.instance
              .collection('Course')
              .doc(documentId)
              .collection(fieldName);
          var subcollectionSnapshot = await subcollectionRef.get();
          if (subcollectionSnapshot.docs.isNotEmpty) {
            subcollectionNames
                .add(subcollectionSnapshot.docs.first.reference.parent.id);
          }
        }
      }

      return subcollectionNames;
    } catch (e) {
      print('Error fetching subcollections: $e');
      rethrow;
    }
  }
}

class SubcollectionDropdown extends StatefulWidget {
  final String documentId;
  final String subcollectionName;
  final String userEmail;

  const SubcollectionDropdown({
    Key? key,
    required this.documentId,
    required this.subcollectionName,
    required this.userEmail,
  }) : super(key: key);

  @override
  _SubcollectionDropdownState createState() => _SubcollectionDropdownState();
}

class _SubcollectionDropdownState extends State<SubcollectionDropdown> {
  String? selectedDocumentName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getDocumentsInSubcollection(
          widget.documentId, widget.subcollectionName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child:
                  Text('No documents found in ${widget.subcollectionName}.'));
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).colorScheme.secondary),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text('Select from ${widget.subcollectionName}'),
            ),
            value: selectedDocumentName,
            items: snapshot.data!.map((documentName) {
              return DropdownMenuItem<String>(
                value: documentName,
                child: Text(documentName),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDocumentName = newValue;
              });
              if (newValue != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirstPage(
                      documentId: widget.documentId,
                      documentName: newValue,
                      subcollectionName: widget.subcollectionName,
                      UserEmail: widget.userEmail,
                    ),
                  ),
                );
                print("Selected Document Name: $newValue");
              }
            },
          ),
        );
      },
    );
  }

  Future<List<String>> getDocumentsInSubcollection(
      String documentId, String subcollectionName) async {
    List<String> documentNames = [];

    try {
      var docRef =
          FirebaseFirestore.instance.collection('Course').doc(documentId);
      var subcollection = await docRef.collection(subcollectionName).get();

      for (var doc in subcollection.docs) {
        documentNames.add(doc.id);
      }

      return documentNames;
    } catch (e) {
      print('Error fetching documents in subcollection: $e');
      rethrow;
    }
  }
}
