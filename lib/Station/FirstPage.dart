import 'package:assets_elerning/Course/dashboard.dart';
import 'package:assets_elerning/Course/stationPage.dart';
import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewie/chewie.dart';

class FirstPage extends StatefulWidget {
  final String documentId;
  final String documentName;
  final String subcollectionName;
  final String UserEmail;

  const FirstPage({
    super.key,
    required this.documentId,
    required this.documentName,
    required this.subcollectionName,
    required this.UserEmail,
  });

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  late VideoPlayerController _controller;
  List<QueryDocumentSnapshot>? userDocs;
  double percentage = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network('');
    fetchCourses(widget.UserEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updatePercentage() async {
    double? newPercentage = await getLoadingComplete(
      widget.documentId,
      widget.subcollectionName,
      widget.documentName,
    );

    if (newPercentage != null) {
      setState(() {
        percentage = newPercentage;
      });
    }
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
                  builder: (context) =>
                      const LoginPage()), // OtherPage() คือหน้าที่คุณต้องการไป
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 155, 154, 154)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: FutureBuilder<List<String>>(
                            future: getNameDocumentSubCollection(
                              widget.documentId,
                              widget.subcollectionName,
                              widget.documentName,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text('No data found.');
                              } else {
                                return Column(
                                  children: snapshot.data!
                                      .map((name) => Text(
                                            name,
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ))
                                      .toList(),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        FutureBuilder<List<String>>(
                          future: getDocumentsInSubcollection(
                            widget.documentId,
                            widget.subcollectionName,
                            widget.documentName,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text('No data found.');
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: snapshot.data!.map((url) {
                                  return Column(
                                    children: [
                                      VideoPlayerWidget(videoUrl: url),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        String? returnDocumentID =
                                            await getReturnDocumentID(
                                                widget.documentId,
                                                widget.subcollectionName,
                                                widget.documentName);
                                        if (returnDocumentID != null) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FirstPage(
                                                        documentId:
                                                            widget.documentId,
                                                        documentName:
                                                            returnDocumentID,
                                                        subcollectionName: widget
                                                            .subcollectionName,
                                                        UserEmail:
                                                            widget.UserEmail,
                                                      )));
                                        } else {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      StationPage(
                                                        documentId:
                                                            widget.documentId,
                                                        UserEmail:
                                                            widget.UserEmail,
                                                      )));
                                        }
                                      },
                                      child: const Text('Previous Lesson'),
                                    ),
                                    const SizedBox(width: 30),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _updatePercentage();
                                        String? nextDocumentID =
                                            await getNextDocumentID(
                                          widget.documentId,
                                          widget.subcollectionName,
                                          widget.documentName,
                                        );
                                        if (nextDocumentID != null) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FirstPage(
                                                documentId: widget.documentId,
                                                documentName: nextDocumentID,
                                                subcollectionName:
                                                    widget.subcollectionName,
                                                UserEmail: widget.UserEmail,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DashboardPage(
                                                userEmail: widget.UserEmail,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Continue'),
                                    ),
                                    const SizedBox(height: 20)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: ProgressIndicatorWidget(
                    subcollection: widget.subcollectionName,
                    userDocs: userDocs,
                    documentId: widget.documentId,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<double?> getLoadingComplete(
      String documentId, String subcollectionName, String documentName) async {
    List<String> loadingComplete = [];
    var docRef =
        FirebaseFirestore.instance.collection('Course').doc(documentId);
    var subcollection = await docRef.collection(subcollectionName).get();

    var loadingStation = await FirebaseFirestore.instance
        .collection('NameStation')
        .doc(documentId)
        .get();

    for (var doc in subcollection.docs) {
      loadingComplete.add(doc.id);
    }

    var nameDocs = userDocs?.map((doc) => doc.id).toList();
    if (nameDocs!.isEmpty) {
      print("No user documents found.");
      return null;
    }

    String firstDocId = nameDocs[0];
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('User')
        .doc(firstDocId)
        .collection('Course')
        .doc(documentId);

    print(
        "--------------------------------------------------------------- $firstDocId -----------------------------------------------");
    double totalDocuments = loadingComplete.length.toDouble();
    double percentageStation = 100 / totalDocuments;

    double totalStation = loadingStation.data()?.length.toDouble() ?? 0;
    double percentageCourse = 100 / totalStation;

    var userDocSnapshot = await userDocRef.get();
    double currentCompleteValue = 0.0;
    double currentCompleteCourse = 0.0;
    if (userDocSnapshot.exists) {
      var data = userDocSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey(subcollectionName)) {
        currentCompleteValue =
            double.parse(data[subcollectionName].replaceAll("%", ""));
      }
      if (data.containsKey("Complete $documentId")) {
        currentCompleteCourse =
            double.parse(data["Complete $documentId"].replaceAll("%", ""));
      }
    }

    double newCompleteValue = currentCompleteValue + percentageStation;
    double newCompleteCourse = currentCompleteCourse + percentageCourse;

    if (newCompleteCourse > 100) {
      newCompleteCourse = 100;
    }

    Map<String, dynamic> updateData = {
      subcollectionName: "${newCompleteValue.toStringAsFixed(2)}%",
    };

    if (newCompleteValue >= 99.99) {
      newCompleteValue = 100;
      updateData[subcollectionName] = "${newCompleteValue.toStringAsFixed(2)}%";
      updateData["Complete $subcollectionName"] =
          "Complete : $subcollectionName";
      updateData["Complete $documentId"] =
          "${newCompleteCourse.toStringAsFixed(2)}%";

      if (newCompleteCourse == 100) {
        await setUpdateComplete("Complete : $documentId", documentId,
            subcollectionName, newCompleteValue);
      }
    }

    await userDocRef.update(updateData);

    return newCompleteValue;
  }

  Future<void> setUpdateComplete(String docsStatus, String documentId,
      String subcollectionName, double newCompleteValue) async {
    var nameDocs = userDocs?.map((doc) => doc.id).toList() ?? [];
    if (nameDocs.isEmpty) {
      print("No user documents found.");
      return;
    }

    String firstDocId = nameDocs[0];
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('User').doc(firstDocId);

    var docRef = userDocRef.collection("CompleteCourse").doc(documentId);
    await docRef.set({
      documentId: "${newCompleteValue.toStringAsFixed(2)}%",
      "Status": docsStatus,
      "Complete $documentId": "Complete Course : $documentId"
    });
  }

  // Future<String> _fetchStatusData(
  //     String documentId, List<String> nameDocs) async {
  //   try {
  //     String firstDocId = nameDocs.isNotEmpty ? nameDocs[0] : '';
  //     DocumentReference userDocRef = FirebaseFirestore.instance
  //         .collection('User')
  //         .doc(firstDocId)
  //         .collection('Course')
  //         .doc(documentId);
  //     var userDocSnapshot = await userDocRef.get();
  //     if (userDocSnapshot.exists) {
  //       var data = userDocSnapshot.data() as Map<String, dynamic>?;
  //       if (data != null && data.containsKey('Status')) {
  //         return data['Status'];
  //       }
  //     }
  //   } catch (e) {
  //     print('Error fetching getData: $e');
  //   }
  //   return 'StatusNotFound';
  // }

  Future<String?> getReturnDocumentID(
      String documentId, String subcollectionName, String documentName) async {
    List<String> documentNames = [];

    try {
      var docRef =
          FirebaseFirestore.instance.collection('Course').doc(documentId);
      var subcollection = await docRef.collection(subcollectionName).get();

      for (var doc in subcollection.docs) {
        documentNames.add(doc.id);
      }

      int currentIndex = documentNames.indexOf(documentName);

      if (currentIndex != -1 && currentIndex > 0) {
        return documentNames[currentIndex - 1];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching documents in subcollection: $e');
      rethrow;
    }
  }

  Future<String?> getNextDocumentID(
      String documentId, String subcollectionName, String documentName) async {
    List<String> documentNames = [];

    try {
      var docRef =
          FirebaseFirestore.instance.collection('Course').doc(documentId);
      var subcollection = await docRef.collection(subcollectionName).get();

      for (var doc in subcollection.docs) {
        documentNames.add(doc.id);
      }

      int currentIndex = documentNames.indexOf(documentName);

      if (currentIndex != -1 && currentIndex < documentNames.length - 1) {
        return documentNames[currentIndex + 1];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching documents in subcollection: $e');
      rethrow;
    }
  }

  Future<List<String>> getNameDocumentSubCollection(
      String documentId, String subcollectionName, String documentName) async {
    List<String> nameStation = [];
    try {
      var docRef = FirebaseFirestore.instance
          .collection('Course')
          .doc(documentId)
          .collection(subcollectionName)
          .doc(documentName);
      var docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        var nameStationData = data?['stationname'];
        if (nameStationData is List) {
          nameStation = List<String>.from(nameStationData);
        } else if (nameStationData is String) {
          nameStation = [nameStationData];
        }
      }
    } catch (e) {
      print("Error: $e");
    }
    return nameStation;
  }

  Future<List<String>> getDocumentsInSubcollection(
      String documentId, String subcollectionName, String documentName) async {
    List<String> videoUrls = [];

    try {
      var docRef = FirebaseFirestore.instance
          .collection('Course')
          .doc(documentId)
          .collection(subcollectionName)
          .doc(documentName);

      var docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        var videos = data?['videosurl'];

        if (videos != null) {
          if (videos is String) {
            videoUrls = [videos];
          } else if (videos is List) {
            videoUrls = List<String>.from(videos);
          } else {
            print('Unexpected type for videosurl: ${videos.runtimeType}');
          }
        }
      }
    } catch (e) {
      print('Error fetching document: $e');
    }

    return videoUrls;
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
      looping: false,
      allowPlaybackSpeedChanging: true,
      aspectRatio: 16 / 9,
      autoPlay: false,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );

    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideoInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}

class ProgressIndicatorWidget extends StatelessWidget {
  final List<QueryDocumentSnapshot>? userDocs;
  final String documentId;
  final String subcollection;

  const ProgressIndicatorWidget({
    super.key,
    required this.userDocs,
    required this.documentId,
    required this.subcollection,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: getValueData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          double currentCompleteValue = snapshot.data ?? 0.0;
          return Container(
            padding: const EdgeInsets.all(4.0),
            height: 100,
            decoration: BoxDecoration(
              border:
                  Border.all(color: const Color.fromARGB(255, 155, 154, 154)),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Complete Course ${currentCompleteValue.toInt()}%'),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: currentCompleteValue / 100,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<double> getValueData() async {
    var nameDocs = userDocs!.map((doc) => doc.id).toList();
    String firstDocId = nameDocs.isNotEmpty ? nameDocs[0] : '';

    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('User')
        .doc(firstDocId)
        .collection('Course')
        .doc(documentId);

    double currentCompleteValue = 0.0;
    var userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      var data = userDocSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey(subcollection)) {
        currentCompleteValue =
            double.parse(data[subcollection].replaceAll("%", ""));
      }
    }

    return currentCompleteValue;
  }
}
