import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCoursePage extends StatefulWidget {
  @override
  _DeleteCoursePageState createState() => _DeleteCoursePageState();
}

class _DeleteCoursePageState extends State<DeleteCoursePage> {
  List<QueryDocumentSnapshot>? userDocs;

  @override
  void initState() {
    super.initState();
    fetchName();
  }

  Future<void> fetchName() async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('Course');
      var querySnapshot = await collectionRef.get();
      setState(() {
        userDocs = querySnapshot.docs;
      });
    } catch (e) {
      print("Error fetching user documents: $e");
    }
  }

  Future<List<String>> getDataDropdown(QueryDocumentSnapshot document) async {
    List<String> dataNames = [];

    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('NameStation')
          .doc(document.id)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();
        var fieldNames = data?.keys.toList();

        for (var fieldName in fieldNames!) {
          var fieldValue = data?[fieldName];
          print('DatafieldName: $fieldValue');

          var subcollectionRef = FirebaseFirestore.instance
              .collection('Course')
              .doc(document.id)
              .collection(fieldName);
          var subcollectionSnapshot = await subcollectionRef.get();
          if (subcollectionSnapshot.docs.isNotEmpty) {
            dataNames.add(subcollectionSnapshot.docs.first.reference.parent.id);
          }
        }
      }
    } catch (e, stackTrace) {
      print("Error fetching dropdown data: $e\n$stackTrace");
    }

    return dataNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: userDocs == null || userDocs!.isEmpty
                        ? Center(child: Text('No courses found'))
                        : ListView.builder(
                            itemCount: userDocs!.length,
                            itemBuilder: (context, index) {
                              var document = userDocs![index];
                              var documentName = document.id;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 155, 154, 154)),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 155, 154, 154)),
                                        ),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(documentName),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CourseDropdownColumn(
                                          document: document,
                                          getDataDropdown: getDataDropdown,
                                          onCourseDeleted: () {
                                            fetchName(); // Refresh userDocs
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CourseDropdownColumn extends StatefulWidget {
  final QueryDocumentSnapshot document;
  final Future<List<String>> Function(QueryDocumentSnapshot) getDataDropdown;
  final VoidCallback? onCourseDeleted;

  const CourseDropdownColumn({
    Key? key,
    required this.document,
    required this.getDataDropdown,
    this.onCourseDeleted,
  }) : super(key: key);

  @override
  _CourseDropdownColumnState createState() => _CourseDropdownColumnState();
}

class _CourseDropdownColumnState extends State<CourseDropdownColumn> {
  String? selectedValue;
  List<String> dropdownItems = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      List<String> data = await widget.getDataDropdown(widget.document);
      setState(() {
        dropdownItems = data;
        if (dropdownItems.isNotEmpty) {
          selectedValue = dropdownItems[0];
        }
      });
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }
  }

  Future<void> deleteSelectedCourse() async {
    try {
      var CourseRef = FirebaseFirestore.instance
          .collection('Course')
          .doc(widget.document.id);

      var subCollectionRef = FirebaseFirestore.instance
          .collection('NameStation')
          .doc(widget.document.id);

      var userRef = FirebaseFirestore.instance.collection('User');
      QuerySnapshot userSnapshot = await userRef.get();

      if (selectedValue == null) {
        await CourseRef.delete();
        await subCollectionRef.delete();
        for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
          CollectionReference courseRef =
              userDoc.reference.collection('Course');
          DocumentReference courseDocRef = courseRef.doc(widget.document.id);
          await courseDocRef.delete();
        }
        setState(() {});
        widget.onCourseDeleted?.call();
        return;
      }

      var subcollectionRef = CourseRef.collection(selectedValue!);
      var querySnapshot = await subcollectionRef.get();

      if (querySnapshot.docs.isEmpty) {
        print('No courses found in subcollection: $selectedValue');
        return;
      }

      var batch = FirebaseFirestore.instance.batch();
      querySnapshot.docs.forEach((doc) async {
        batch.delete(doc.reference);
        await subCollectionRef.update({selectedValue!: FieldValue.delete()});
      });
      await batch.commit();

      print('Deleted all courses in subcollection: $selectedValue');
      await fetchDropdownData();

      setState(() {
        selectedValue = dropdownItems.isNotEmpty ? dropdownItems[0] : null;
      });
      widget.onCourseDeleted?.call();
    } catch (e) {
      print('Error deleting courses in subcollection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 40,
              child: dropdownItems.isEmpty
                  ? Center(child: Text('No courses found'))
                  : DropdownButton<String>(
                      value: selectedValue,
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      },
                      items: dropdownItems.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: deleteSelectedCourse,
          child: Text('Delete'),
        ),
      ],
    );
  }
}
