// import 'package:chewie/chewie.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo2_assets_elerning/Course/dashboard.dart';
// import 'package:demo2_assets_elerning/LoginAndSignup/Login.dart';
// import 'package:demo2_assets_elerning/Station/FirstPage.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class SecondPage extends StatefulWidget {
//   final String documentId;
//   final String documentName;
//   final String subcollectionName;

//   const SecondPage({
//     required this.documentId,
//     required this.documentName,
//     required this.subcollectionName,
//   });

//   @override
//   _SecondePage createState() => _SecondePage();
// }

// class _SecondePage extends State<SecondPage> {
//   late VideoPlayerController _controller;

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         title: GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       LoginPage()), // OtherPage() คือหน้าที่คุณต้องการไป
//             );
//           },
//           child: Image.asset('images/logo1.png', fit: BoxFit.contain),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(4.0),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Color.fromARGB(255, 155, 154, 154)),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Center(
//                         child: FutureBuilder<List<String>>(
//                           future: getNameDocumentSubCollection(
//                             widget.documentId,
//                             widget.subcollectionName,
//                             widget.documentName,
//                           ),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return CircularProgressIndicator();
//                             } else if (snapshot.hasError) {
//                               return Text('Error: ${snapshot.error}');
//                             } else if (!snapshot.hasData ||
//                                 snapshot.data!.isEmpty) {
//                               return Text('No data found.');
//                             } else {
//                               // Display the list of station names
//                               return Column(
//                                 children: snapshot.data!
//                                     .map((name) => Text(name))
//                                     .toList(),
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       FutureBuilder<List<String>>(
//                         future: getDocumentsInSubcollection(
//                           widget.documentId,
//                           widget.subcollectionName,
//                           widget.documentName,
//                         ),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return CircularProgressIndicator();
//                           } else if (snapshot.hasError) {
//                             return Text('Error: ${snapshot.error}');
//                           } else if (!snapshot.hasData ||
//                               snapshot.data!.isEmpty) {
//                             return Text('No data found.');
//                           } else {
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: snapshot.data!.map((url) {
//                                 return Column(
//                                   children: [
//                                     VideoPlayerWidget(videoUrl: url),
//                                     SizedBox(height: 10),
//                                   ],
//                                 );
//                               }).toList(),
//                             );
//                           }
//                         },
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: Row(
//                                 children: [
//                                   ElevatedButton(
//                                     onPressed: () async {
//                                       String? returnDocumentID =
//                                           await getReturnDocumentID(
//                                               widget.documentId,
//                                               widget.subcollectionName,
//                                               widget.documentName);
//                                       String? nextDocumentID =
//                                           await getNextDocumentID(
//                                               widget.documentId,
//                                               widget.subcollectionName,
//                                               widget.documentName);
//                                       print(returnDocumentID);
//                                       if (returnDocumentID != null) {
//                                         if (returnDocumentID ==
//                                             nextDocumentID) {
//                                           Navigator.pushReplacement(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) => FirstPage(
//                                                       documentId:
//                                                           widget.documentId,
//                                                       documentName:
//                                                           returnDocumentID,
//                                                       subcollectionName: widget
//                                                           .subcollectionName)));
//                                         } else {
//                                           Navigator.pushReplacement(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) => SecondPage(
//                                                       documentId:
//                                                           widget.documentId,
//                                                       documentName:
//                                                           returnDocumentID,
//                                                       subcollectionName: widget
//                                                           .subcollectionName)));
//                                         }
//                                       } else {
//                                         Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     dashboardPage()));
//                                       }
//                                     },
//                                     child: Text('Previous Lesson'),
//                                   ),
//                                   SizedBox(
//                                     width: 30,
//                                   ),
//                                   ElevatedButton(
//                                     onPressed: () async {
//                                       String? nextDocumentID =
//                                           await getNextDocumentID(
//                                               widget.documentId,
//                                               widget.subcollectionName,
//                                               widget.documentName);
//                                       print(nextDocumentID);
//                                       if (nextDocumentID != null) {
//                                         Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) => SecondPage(
//                                                     documentId:
//                                                         widget.documentId,
//                                                     documentName:
//                                                         nextDocumentID,
//                                                     subcollectionName: widget
//                                                         .subcollectionName)));
//                                       } else {
//                                         Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     dashboardPage()));
//                                       }
//                                     },
//                                     child: Text('Complete and Continue'),
//                                   ),
//                                   SizedBox(
//                                     height: 20,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 80,
//               ),
//               Container(
//                 padding: EdgeInsets.all(4.0),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Color.fromARGB(255, 155, 154, 154)),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Text('Complete Course  0%'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<String?> getReturnDocumentID(
//       String documentId, String subcollectionName, String documentName) async {
//     List<String> documentNames = [];

//     try {
//       var docRef =
//           FirebaseFirestore.instance.collection('Course').doc(documentId);
//       var subcollection = await docRef.collection(subcollectionName).get();

//       for (var doc in subcollection.docs) {
//         documentNames.add(doc.id);
//       }
//       print('Document Names in Subcollection: $documentNames');

//       int currentIndex = documentNames.indexOf(documentName);
//       print('Current Index: $currentIndex and ${documentNames.length}');

//       if (currentIndex != -1 && currentIndex > 0) {
//         return documentNames[currentIndex - 1];
//       } else {
//         return null; // หรือสามารถคืนค่าว่าง '' ได้เช่นกัน
//       }
//     } catch (e) {
//       print('Error fetching documents in subcollection: $e');
//       throw e;
//     }
//   }

//   Future<String?> getNextDocumentID(
//       String documentId, String subcollectionName, String documentName) async {
//     List<String> documentNames = [];

//     try {
//       var docRef =
//           FirebaseFirestore.instance.collection('Course').doc(documentId);
//       var subcollection = await docRef.collection(subcollectionName).get();

//       for (var doc in subcollection.docs) {
//         documentNames.add(doc.id);
//       }
//       print('Document Names in Subcollection: $documentNames');

//       int currentIndex = documentNames.indexOf(documentName);
//       print('Current Index: $currentIndex');

//       if (currentIndex != -1 && currentIndex < documentNames.length - 1) {
//         return documentNames[currentIndex + 1];
//       } else {
//         return null; // หรือสามารถคืนค่าว่าง '' ได้เช่นกัน
//       }
//     } catch (e) {
//       print('Error fetching documents in subcollection: $e');
//       throw e;
//     }
//   }

//   Future<List<String>> getNameDocumentSubCollection(
//       String documentId, String subcollectionName, String documentName) async {
//     List<String> nameStation = [];
//     try {
//       var docref = FirebaseFirestore.instance
//           .collection('Course')
//           .doc(documentId)
//           .collection(subcollectionName)
//           .doc(documentName);
//       var docSnapshot = await docref.get();
//       if (docSnapshot.exists) {
//         var data = docSnapshot.data();
//         var namestation = data?['stationname'];
//         if (namestation is List) {
//           nameStation = List<String>.from(namestation);
//         } else if (namestation is String) {
//           nameStation = [namestation];
//         }
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//     return nameStation;
//   }

//   Future<List<String>> getDocumentsInSubcollection(
//       String documentId, String subcollectionName, String documentName) async {
//     List<String> videoUrls = [];

//     try {
//       var docRef = FirebaseFirestore.instance
//           .collection('Course')
//           .doc(documentId)
//           .collection(subcollectionName)
//           .doc(documentName);

//       var docSnapshot = await docRef.get();
//       if (docSnapshot.exists) {
//         var data = docSnapshot.data();
//         var videos = data?['videosurl'];

//         if (videos != null) {
//           if (videos is String) {
//             videoUrls = [videos];
//           } else if (videos is List) {
//             videoUrls = List<String>.from(videos);
//           } else {
//             print('Unexpected type for videosurl: ${videos.runtimeType}');
//           }
//         }
//       }
//     } catch (e) {
//       print('Error fetching document: $e');
//     }

//     return videoUrls;
//   }
// }

// class VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;

//   const VideoPlayerWidget({required this.videoUrl});

//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _videoPlayerController;
//   late ChewieController _chewieController;

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }

//   void _initializePlayer() async {
//     _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
//     await _videoPlayerController
//         .initialize(); // Ensure controller is initialized

//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       autoInitialize: true,
//       looping: false,
//       allowPlaybackSpeedChanging: true,
//       aspectRatio: 16 / 9,
//       autoPlay: false,
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: Text(
//             errorMessage,
//             style: TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//     setState(() {}); // Update the widget state after initialization
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_videoPlayerController.value.isInitialized) {
//       return Container(
//         width: MediaQuery.of(context).size.width,
//         height: 300,
//         child: Chewie(
//           controller: _chewieController,
//         ),
//       );
//     } else {
//       return Center(
//         child: CircularProgressIndicator(),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     _chewieController.dispose();
//     super.dispose();
//   }
// }
