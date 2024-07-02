import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';
import 'package:flutter/material.dart';

class Loadingscreen extends StatefulWidget {
  const Loadingscreen({super.key});
  @override
  _LoadingscreenPageState createState() => _LoadingscreenPageState();
}

class _LoadingscreenPageState extends State<Loadingscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginPage(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(''),
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Please wait Loading.....',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ));
  }
}
