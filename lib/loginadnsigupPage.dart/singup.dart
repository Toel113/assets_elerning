import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/admin.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/user.dart';
import 'package:flutter/material.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'User Registration'),
            Tab(text: 'Admin Registration'),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            userRegisPageState(),
            adminRegisPage(),
          ],
        ),
      ),
    );
  }
}
