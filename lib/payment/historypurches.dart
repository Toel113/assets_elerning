import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Historypurches extends StatefulWidget {
  final String userEmail;

  Historypurches({required this.userEmail});

  @override
  _HistorypurchesState createState() => _HistorypurchesState();
}

class _HistorypurchesState extends State<Historypurches> {
  List<DocumentSnapshot> historyDocs = [];

  @override
  void initState() {
    super.initState();
    fetchCourses(widget.userEmail);
  }

  Future<void> fetchCourses(String userEmail) async {
    var collectionRef = FirebaseFirestore.instance.collection('User');
    var querySnapshot =
        await collectionRef.where('Email', isEqualTo: userEmail).get();
    var userDocs = querySnapshot.docs;

    if (userDocs.isNotEmpty) {
      var docRef = collectionRef.doc(userDocs.first.id);
      var historySnapshot = await docRef.collection("History").get();
      setState(() {
        historyDocs = historySnapshot.docs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Purchase History",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              historyDocs.isEmpty
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "No purchase history for Course.",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: historyDocs.length,
                        itemBuilder: (context, index) {
                          var data =
                              historyDocs[index].data() as Map<String, dynamic>;
                          var courseName =
                              data['CourseName'] ?? 'Unknown Course';
                          var price = data['Amount'] ?? 'Unknown Price';
                          var courseId = data['Course ID'] ?? 'Unknown ID';
                          var dateTime = data['DateTime'] ?? 'Unknown Date';
                          var statusCheck = data['StatusCheck'] ?? "";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(255, 154, 154, 154)),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courseName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text("Amount: ${price}"),
                                      ),
                                      Expanded(
                                        child: Text("ID: ${courseId}"),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text("Date Time: ${dateTime}"),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "* $statusCheck",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: statusCheck ==
                                              "Successfully received the course."
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
