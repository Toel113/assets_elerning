import 'package:assets_elerning/LoadingPage.dart';
import 'package:assets_elerning/api/firebase.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assets-Elerning',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 235, 234, 237)),
        useMaterial3: true,
      ),
      home: const Loadingscreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
