import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({Key? key});

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, String>> stationData = [];
  PlatformFile? pickedFile;
  String? urlDownload;
  String? urlVideos;

  final Courses courseData = Courses();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize with one blank row
    stationData.add({'stationname': '', 'videosurl': ''});
  }

  Future<void> addCourseToFirestore() async {
    try {
      if (courseData.coursename.isEmpty ||
          courseData.docname.isEmpty ||
          stationData.isEmpty) {
        print('Some fields are empty.');
        return;
      }

      await firestore.collection("Course").doc(courseData.coursename).set({
        "images": urlDownload,
      });

      final courseRef = FirebaseFirestore.instance
          .collection('NameStation')
          .doc(courseData.coursename);

      courseRef.get().then((docSnapshot) {
        if (docSnapshot.exists) {
          courseRef.update({
            courseData.docname: courseData.docname,
          }).then((_) {
            print('Updated document ${courseData.docname} successfully.');
          }).catchError((error) {
            print('Error updating document: $error');
          });
        } else {
          courseRef.set({
            courseData.docname: courseData.docname,
          }).then((_) {
            print('Added document ${courseData.docname} successfully.');
          }).catchError((error) {
            print('Error adding new document: $error');
          });
        }
      }).catchError((error) {
        print('Error checking document: $error');
      });

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
        await uploadTask.whenComplete(() async {
          final urlDownload = await ref.getDownloadURL();
          setState(() {
            this.urlDownload = urlDownload;
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
      final metadata = SettableMetadata(contentType: "Videos/mp4");
      final ref = FirebaseStorage.instance.ref().child('Videos/$fileName');
      final uploadTask = ref.putData(bytes, metadata);
      await uploadTask.whenComplete(() async {
        final urlVideos = await ref.getDownloadURL();
        setState(() {
          stationData[index]['videosurl'] =
              urlVideos; // Save videos URL to stationData
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27.0),
              child: urlVideos != null
                  ? Text(urlVideos!)
                  : ElevatedButton(
                      onPressed: () {
                        selectVideo(index);
                      },
                      child: const Text('Upload Video'),
                    ),
            ),
          ),
        ],
      ),
    );
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
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 27.0),
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
                              courseData.coursename = coursename ?? '';
                            },
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
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 27.0),
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
                          physics: NeverScrollableScrollPhysics(),
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
                            backgroundColor: Colors.blue,
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
}
