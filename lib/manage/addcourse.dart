import 'dart:io';
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
  String? urlDownload, urlVideos;
  double imageUploadProgress = 0.0;
  List<double> videoUploadProgress = [];
  List<String> items2 = ["False", "True"], items1 = [];
  String? selectStatus, selectValue;
  late List<String> DataCourse = [], DataStation = [];
  final Courses courseData = Courses();
  final _formKey = GlobalKey<FormState>();
  var rng = RandomNumberGenerator();

  @override
  void initState() {
    super.initState();
    stationData.add({'stationname': '', 'videosurl': ''});
    videoUploadProgress.add(0.0);
    getDocument();
    fetchDropdownDataStatus();
    getCourse();
    getStation();
  }

  Future<void> fetchDropdownDataStatus() async {
    setState(() {
      if (items2.isNotEmpty) {
        selectStatus = items2[0];
      }
    });
  }

  Future<void> addCourseToFirestore() async {
    try {
      if (selectValue == "newValue") {
        if (!DataCourse.contains(courseData.coursename)) {
          if (courseData.coursename.isEmpty ||
              courseData.docname.isEmpty ||
              stationData.isEmpty) {
            print('Some fields are empty.');
            return;
          }

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
          if (!DataStation.contains(courseData.docname)) {
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
        }
      } else {
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

      final pickedFile = result.files.first;
      print(pickedFile.name);

      if (pickedFile.bytes != null) {
        // หาก bytes มีค่า
        final bytes = pickedFile.bytes!;
        final fileName = pickedFile.name;
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
          try {
            final urlDownload = await ref.getDownloadURL();
            setState(() {
              this.urlDownload = urlDownload;
              imageUploadProgress = 0.0;
            });
            print('Download URL: $urlDownload');
          } catch (e) {
            print('Error getting download URL: $e');
          }
        });
      } else if (pickedFile.path != null) {
        // หาก bytes เป็นค่าว่าง แต่ path มีค่า
        final file = File(pickedFile.path!);
        final fileName = pickedFile.name;
        final metadata = SettableMetadata(contentType: "image/jpeg");
        final ref = FirebaseStorage.instance.ref().child('files/$fileName');
        final uploadTask = ref.putFile(file, metadata);

        uploadTask.snapshotEvents.listen((taskSnapshot) {
          setState(() {
            imageUploadProgress = (taskSnapshot.bytesTransferred.toDouble() /
                taskSnapshot.totalBytes.toDouble());
          });
        });

        await uploadTask.whenComplete(() async {
          try {
            final urlDownload = await ref.getDownloadURL();
            setState(() {
              this.urlDownload = urlDownload;
              imageUploadProgress = 0.0;
            });
            print('Download URL: $urlDownload');
          } catch (e) {
            print('Error getting download URL: $e');
          }
        });
      } else {
        print('File bytes and path are null');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> selectVideo(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result == null || result.files.isEmpty) {
        print('No file selected');
        return;
      }

      final pickedFile = result.files.first;

      final bytes = pickedFile.bytes;
      final path = pickedFile.path;
      if (bytes == null && path == null) {
        print('Error: both bytes and path are null');
        return;
      }

      final fileName = pickedFile.name;
      final metadata = SettableMetadata(contentType: "video/mp4");
      final ref = FirebaseStorage.instance.ref().child('Videos/$fileName');

      UploadTask uploadTask;
      if (bytes != null) {
        uploadTask = ref.putData(bytes, metadata);
      } else if (path != null) {
        final file = File(path);
        uploadTask = ref.putFile(file, metadata);
      } else {
        print('Error: unable to upload file');
        return;
      }

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
              urlVideos; // บันทึก URL ของวิดีโอไปยัง stationData
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
                decoration: InputDecoration(
                  labelText: 'Station name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter station name';
                  }
                  return null;
                },
                onSaved: (String? stationname) {
                  stationData[index]['stationname'] = stationname ?? '';
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                IconButton(
                  onPressed: () => selectVideo(index),
                  icon: Icon(Icons.video_library),
                ),
                if (videoUploadProgress[index] > 0)
                  LinearProgressIndicator(
                    value: videoUploadProgress[index],
                  ),
              ],
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

  Future<void> getCourse() async {
    var docRef = FirebaseFirestore.instance.collection('Course');

    try {
      var snapshot = await docRef.get();
      for (var data in snapshot.docs) {
        DataCourse.add(data.id);
      }
    } catch (e) {
      print("Error getting documents: $e");
    }
  }

  Future<Map<String, dynamic>> getStation() async {
    try {
      DocumentReference docRef;
      if (selectValue == "newValue") {
        docRef = FirebaseFirestore.instance
            .collection('NameStation')
            .doc(courseData.coursename);
      } else {
        docRef = FirebaseFirestore.instance
            .collection('NameStation')
            .doc(selectValue);
      }

      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        return data;
      } else {
        throw Exception("Document does not exist");
      }
    } catch (e) {
      print("Error getting document: $e");
      throw e;
    }
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
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: DropdownButtonFormField<String>(
                            value: selectValue,
                            items: items1
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item),
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectValue = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Select Course Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        if (selectValue == "newValue")
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: DropdownButtonFormField<String>(
                              value: selectStatus,
                              items: items2
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item),
                                      ))
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectStatus = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Select Status',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        if (selectValue == "newValue")
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  courseData.coursename = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Course name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a course name';
                                }
                                if (DataCourse.contains(
                                    courseData.coursename)) {
                                  return 'This Course already exists';
                                }
                                return null;
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                courseData.docname = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Document name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a document name';
                              }
                              if (DataStation.contains(courseData.docname)) {
                                return 'This Station Already exists';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (selectStatus == "True")
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  courseData.amountCourse = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Amount of courses',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the amount of courses';
                                }
                                return null;
                              },
                            ),
                          ),
                        if (selectValue == "newValue")
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: selectFile,
                                  icon: Icon(Icons.attach_file),
                                  label: Text('Upload Image'),
                                ),
                                if (imageUploadProgress > 0)
                                  LinearProgressIndicator(
                                    value: imageUploadProgress,
                                  ),
                              ],
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
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();
                                addCourseToFirestore();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.fromLTRB(
                                  60.0, 20.0, 60.0, 20.0),
                            ),
                            icon: Icon(Icons.save),
                            label: Text('Save'),
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
