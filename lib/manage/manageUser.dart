import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({Key? key}) : super(key: key);

  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  List<QueryDocumentSnapshot>? userDocs;

  @override
  void initState() {
    super.initState();
    fetchName();
  }

  Future<void> fetchName() async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('User');
      var querySnapshot = await collectionRef.get();
      setState(() {
        userDocs = querySnapshot.docs;
      });
    } catch (e) {
      print("Error fetching user documents: $e");
    }
  }

  Future<String> getDatashowName(QueryDocumentSnapshot document) async {
    String fullname = '';
    try {
      var data = document.data() as Map<String, dynamic>?;
      if (data != null) {
        var fullnameData = data['Fullname'];
        if (fullnameData is String) {
          fullname = fullnameData;
        } else {
          print("Fullname is not a string: $fullnameData");
        }
      } else {
        print("Document data is null");
      }
    } catch (e, stackTrace) {
      print("Error fetching fullname: $e\n$stackTrace");
    }
    return fullname;
  }

  Future<List<String>> getDataDropdown(QueryDocumentSnapshot document) async {
    List<String> dataNames = [];

    try {
      var docRef =
          FirebaseFirestore.instance.collection('User').doc(document.id);
      var snapshotData = await docRef.collection('Course').get();

      snapshotData.docs.forEach((doc) {
        dataNames.add(doc.id);
      });
    } catch (e, stackTrace) {
      print("Error fetching dropdown data: $e\n$stackTrace");
    }

    return dataNames;
  }

  Future<void> _refresh() async {
    await fetchName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Manage User'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: const Color.fromARGB(255, 155, 154, 154)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        itemCount: userDocs?.length ?? 0,
                        itemBuilder: (context, index) {
                          var document = userDocs![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: NameColumn(
                                    document: document,
                                    getDatashowName: getDatashowName,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  flex: 3,
                                  child: CourseDropdownColumn(
                                    document: document,
                                    getDataDropdown: getDataDropdown,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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

class NameColumn extends StatelessWidget {
  final QueryDocumentSnapshot document;
  final Future<String> Function(QueryDocumentSnapshot) getDatashowName;

  const NameColumn({
    Key? key,
    required this.document,
    required this.getDatashowName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: FutureBuilder<String>(
        future: getDatashowName(document),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            String fullname = snapshot.data ?? 'Unknown';
            return Center(child: Text(fullname));
          }
        },
      ),
    );
  }
}

class CourseDropdownColumn extends StatefulWidget {
  final QueryDocumentSnapshot document;
  final Future<List<String>> Function(QueryDocumentSnapshot) getDataDropdown;

  const CourseDropdownColumn({
    Key? key,
    required this.document,
    required this.getDataDropdown,
  }) : super(key: key);

  @override
  _CourseDropdownColumnState createState() => _CourseDropdownColumnState();
}

class _CourseDropdownColumnState extends State<CourseDropdownColumn> {
  String? selectedValue1;
  String? selectStatus;
  List<String> items1 = [];
  List<String> items2 = ["False", "True"];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
    fetchDropdownDataStatus();
  }

  Future<void> fetchDropdownData() async {
    try {
      List<String> data = await widget.getDataDropdown(widget.document);
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

  Future<void> fetchDropdownDataStatus() async {
    setState(() {
      if (items2.isNotEmpty) {
        selectStatus = items2[0]; // Default selection
      }
    });
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
                        : DropdownButton<String>(
                            value: selectedValue1,
                            onChanged: (newValue) {
                              setState(() {
                                selectedValue1 = newValue;
                                getDataStatus();
                              });
                            },
                            items: items1.map((String document) {
                              return DropdownMenuItem<String>(
                                value: document,
                                child: Text(document),
                              );
                            }).toList(),
                          ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                height: 40,
                child: items2.isEmpty
                    ? Center(child: Text('No courses found'))
                    : DropdownButton<String>(
                        value: selectStatus,
                        onChanged: (newValue) {
                          setState(() {
                            selectStatus = newValue;
                            getfield();
                          });
                        },
                        items: items2.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDataStatus() async {
    String? documentId = widget.document.id;
    if (selectedValue1 != null) {
      var dataStatus =
          FirebaseFirestore.instance.collection('User').doc(documentId);
      var userDocSnapshot =
          await dataStatus.collection('Course').doc(selectedValue1!).get();
      if (userDocSnapshot.exists) {
        var status = userDocSnapshot.data()?['Status'];
        setState(() {
          if (status == "False") {
            selectStatus = items2[0];
          } else if (status == "True") {
            selectStatus = items2[1];
          }
        });
      } else {
        print('Document does not exist');
      }
    } else {
      print('Document ID or selectedValue1 is null');
    }
  }

  Future<void> getfield() async {
    String? documentId = widget.document.id;
    if (selectedValue1 != null) {
      var dataStatus =
          FirebaseFirestore.instance.collection('User').doc(documentId);
      var userDocRef = dataStatus.collection('Course').doc(selectedValue1!);
      await userDocRef.update({
        "Status": selectStatus,
      });
    } else {
      print('Document ID or selectedValue1 is null');
    }
  }
}
