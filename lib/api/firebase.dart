import 'package:firebase_core/firebase_core.dart';

Future<FirebaseApp> initializeFirebase() async {
  FirebaseApp firebase = await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBzaV2QUvlUBBdQlRWTHbddbxatyw_MsqI",
      projectId: "assets-elernning-1a64e",
      messagingSenderId: "564309313172",
      appId: "1:564309313172:android:3a47daf3b7d69a21aed681",
      storageBucket: "gs://assets-elernning-1a64e.appspot.com",
    ),
  );
  return firebase;
}
