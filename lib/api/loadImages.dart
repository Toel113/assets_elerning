import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getUrlImages1() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot doc =
      await firestore.collection('logo').doc('images 1').get();
  if (doc.exists) {
    String imageUrl = doc['url'];
    return imageUrl;
  } else {
    throw Exception('Document not found or field "images" does not exist');
  }
}
