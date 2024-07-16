import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({Key? key});

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class RandomNumberGenerator {
  late int randomNumber;

  RandomNumberGenerator() {
    var random = Random();
    randomNumber = random.nextInt(1000000);
  }
}

class _AddCoursePageState extends State<AddCoursePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, String>> stationData = [];
  PlatformFile? pickedFile;
  String? urlDownload;
  String? urlVideos;
  double imageUploadProgress = 0.0;
  List<double> videoUploadProgress = [];

  List<String> items2 = ["False", "True"];
  String? selectStatus;

  List<String> items1 = [];
  String? selectValue;

  final Courses courseData = Courses();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    stationData.add({'stationname': '', 'videosurl': ''});
    videoUploadProgress.add(0.0);
    getDocument();
    fetchDropdownDataStatus();
  }

  Future<void> fetchDropdownDataStatus() async {
    setState(() {
      if (items2.isNotEmpty) {
        selectStatus = items2[0];
      }
    });
  }

  var rng = RandomNumberGenerator();

  Future<void> addCourseToFirestore() async {
    try {
      if (courseData.coursename.isEmpty ||
          courseData.docname.isEmpty ||
          stationData.isEmpty) {
        print('Some fields are empty.');
        return;
      }
      // SelectValue == "newValue"
      if (selectValue == "newValue") {
        var courseRef =
            firestore.collection("Course").doc(courseData.coursename);
        var docSnapshot = await courseRef.get();

        if (docSnapshot.exists) {
          var data = docSnapshot.data();
          if (data != null && data.containsKey("Course ID")) {
            await courseRef.update({
              "images": urlDownload,
            });
            if (data.containsKey("Status") != selectStatus) {
              await courseRef.update({
                "Status": selectStatus,
                "images": urlDownload,
              });
            }
          }
        } else {
          await courseRef.set({
            "Amount": courseData.amountCourse,
            "Status": selectStatus,
            "Course ID": "00${rng.randomNumber}",
            "images": urlDownload,
          });
        }

        final nameStationRef =
            firestore.collection('NameStation').doc(courseData.coursename);
        var nameStationSnapshot = await nameStationRef.get();

        if (nameStationSnapshot.exists) {
          await nameStationRef.update({
            courseData.docname: courseData.docname,
          });
          print('Updated document ${courseData.docname} successfully.');
        } else {
          await nameStationRef.set({
            courseData.docname: courseData.docname,
          });
          print('Added document ${courseData.docname} successfully.');
        }

        for (var station in stationData) {
          await firestore
              .collection("Course")
              .doc(courseData.coursename)
              .collection(courseData.docname)
              .doc(station['stationname'])
              .set({
            "stationname": station['stationname'],
            "videosurl": station['videosurl'],
          });
          print(
              "Added ${station['stationname']} under ${courseData.docname} successfully.");
        }
        print(
            "Course ${courseData.coursename} with document ${courseData.docname} added successfully.");
      }

      /// SelectValue != "newValue" or SelectValue == "nameCourse"
      else {
        final nameStationRef =
            firestore.collection('NameStation').doc(selectValue);
        var nameStationSnapshot = await nameStationRef.get();

        if (nameStationSnapshot.exists) {
          await nameStationRef.update({
            courseData.docname: courseData.docname,
          });
          print('Updated document ${courseData.docname} successfully.');
        } else {
          await nameStationRef.set({
            courseData.docname: courseData.docname,
          });
          print('Added document ${courseData.docname} successfully.');
        }

        for (var station in stationData) {
          await firestore
              .collection("Course")
              .doc(selectValue)
              .collection(courseData.docname)
              .doc(station['stationname'])
              .set({
            "stationname": station['stationname'],
            "videosurl": station['videosurl'],
          });
          print(
              "Added ${station['stationname']} under ${courseData.docname} successfully.");
        }

        print(
            "Course ${courseData.coursename} with document ${courseData.docname} added successfully.");
      }
    } catch (error) {
      print("Error adding course to Firestore: $error");
    }
  }

  Future<void> selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) {
        print('No file selected');
        return;
      }

      setState(() {
        pickedFile = result.files.first;
        print(pickedFile!.name);
      });

      if (pickedFile != null && pickedFile!.bytes != null) {
        final bytes = pickedFile!.bytes!;
        final fileName = pickedFile!.name;
        final metadata = SettableMetadata(contentType: "image/jpeg");
        final ref = FirebaseStorage.instance.ref().child('files/$fileName');
        final uploadTask = ref.putData(bytes, metadata);

        uploadTask.snapshotEvents.listen((taskSnapshot) {
          setState(() {
            imageUploadProgress = (taskSnapshot.bytesTransferred.toDouble() /
                taskSnapshot.totalBytes.toDouble());
          });
        });

        await uploadTask.whenComplete(() async {
          final urlDownload = await ref.getDownloadURL();
          setState(() {
            this.urlDownload = urlDownload;
            imageUploadProgress = 0.0;
          });
          print('Download URL: $urlDownload');
        });
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> selectVideo(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) {
        print('No file selected');
        return;
      }

      final pickedFile = result.files.first;
      final bytes = pickedFile.bytes!;
      final fileName = pickedFile.name;
      final metadata = SettableMetadata(contentType: "video/mp4");
      final ref = FirebaseStorage.instance.ref().child('Videos/$fileName');
      final uploadTask = ref.putData(bytes, metadata);

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        setState(() {
          videoUploadProgress[index] =
              (taskSnapshot.bytesTransferred.toDouble() /
                  taskSnapshot.totalBytes.toDouble());
        });
      });

      await uploadTask.whenComplete(() async {
        final urlVideos = await ref.getDownloadURL();
        setState(() {
          stationData[index]['videosurl'] =
              urlVideos; // Save videos URL to stationData
          videoUploadProgress[index] = 0.0;
        });
        print('Download URL: $urlVideos');
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Widget createRow(int index) {
    TextEditingController stationNameController = TextEditingController();
    stationNameController.text = stationData[index]['stationname'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27.0),
              child: TextFormField(
                controller: stationNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your Station name',
                  labelText: 'Station Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter station name';
                  }
                  return null;
                },
                onSaved: (String? stationname) {
                  // Save station name to stationData
                  stationData[index]['stationname'] = stationname ?? '';
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      selectVideo(index);
                    },
                    child: const Text('Upload Video'),
                  ),
                  if (videoUploadProgress[index] > 0)
                    LinearProgressIndicator(
                      value: videoUploadProgress[index],
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  stationData.removeAt(index);
                  videoUploadProgress.removeAt(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDocument() async {
    List<String> documentIds = [];
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection("Course").get();

    for (QueryDocumentSnapshot doc in docRef.docs) {
      documentIds.add(doc.id);
    }
    print("Doc ID : $documentIds");
    documentIds.insert(0, 'newValue');

    setState(() {
      items1 = documentIds;
      selectValue = 'newValue';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 155, 154, 154)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        Container(
                          child: items1.isEmpty
                              ? Center(child: Text('No courses found'))
                              : DropdownMenu<String>(
                                  initialSelection: selectValue,
                                  onSelected: (newValue) {
                                    setState(() {
                                      selectValue = newValue;
                                    });
                                  },
                                  dropdownMenuEntries: items1.map((document) {
                                    return DropdownMenuEntry<String>(
                                      value: document,
                                      label: document,
                                    );
                                  }).toList(),
                                ),
                        ),
                        if (selectValue == "newValue")
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 27.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          hintText: 'Enter your Course name',
                                          labelText: 'Course Name',
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter course name';
                                          }
                                          return null;
                                        },
                                        onSaved: (String? coursename) {
                                          courseData.coursename =
                                              coursename ?? '';
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text("Payment"),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Container(
                                              height: 40,
                                              child: items2.isEmpty
                                                  ? const Center(
                                                      child: Text(
                                                          'No courses found'))
                                                  : DropdownButton<String>(
                                                      value: selectStatus,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          selectStatus =
                                                              newValue!;
                                                        });
                                                      },
                                                      items: items2
                                                          .map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: selectFile,
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    'Upload Image',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (imageUploadProgress > 0)
                          LinearProgressIndicator(
                            value: imageUploadProgress,
                          ),
                        const SizedBox(height: 15),
                        if (selectStatus == "True")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 27.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your Document name',
                                      labelText: 'Document Name',
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter document name';
                                      }
                                      return null;
                                    },
                                    onSaved: (String? docname) {
                                      courseData.docname = docname ?? '';
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 27.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Amount Course',
                                      labelText: 'Amount Course',
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter Amount Course';
                                      }
                                      return null;
                                    },
                                    onSaved: (String? amountCourse) {
                                      courseData.amountCourse =
                                          amountCourse ?? '';
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 27.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Enter your Document name',
                                labelText: 'Document Name',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter document name';
                                }
                                return null;
                              },
                              onSaved: (String? docname) {
                                courseData.docname = docname ?? '';
                              },
                            ),
                          ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stationData.length,
                          itemBuilder: (context, index) {
                            return createRow(index);
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              stationData
                                  .add({'stationname': '', 'videosurl': ''});
                              videoUploadProgress.add(0.0);
                            });
                          },
                          child: const Text('Add Row'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _formKey.currentState?.save();
                              addCourseToFirestore();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(
                                60.0, 30.0, 60.0, 30.0),
                          ),
                          child: const Text(
                            'Add Course',
                            style: TextStyle(
                              fontSize: 25.0,
                              color: Color.fromARGB(255, 31, 31, 31),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Courses {
  String coursename = '';
  String docname = '';
  String amountCourse = '';
}
