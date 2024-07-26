import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';
import 'package:assets_elerning/manage/manageCourse.dart';
import 'package:assets_elerning/manage/manageUser.dart';
import 'package:flutter/material.dart';

class MainmanagePage extends StatefulWidget {
  const MainmanagePage({super.key});

  @override
  _MainmanagePageState createState() => _MainmanagePageState();
}

class _MainmanagePageState extends State<MainmanagePage> {
  int myIndex = 0;
  final List<Widget> _children = [
    const ManagePage(),
    ManageUserPage(key: UniqueKey()), // Add UniqueKey here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myIndex != 2
          ? AppBar(
              automaticallyImplyLeading: false,
              title: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainmanagePage()),
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
            )
          : null,
      body: IndexedStack(
        index: myIndex,
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myIndex,
        selectedItemColor: const Color.fromARGB(255, 24, 24, 24),
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            setState(() {
              myIndex = index;
              if (index == 1) {
                _children[1] =
                    ManageUserPage(key: UniqueKey()); // Update the key
              }
            });
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: Color.fromARGB(255, 22, 22, 22)),
            label: 'Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color.fromARGB(255, 20, 20, 20)),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout, color: Color.fromARGB(255, 22, 22, 22)),
            label: 'Log out',
          ),
        ],
      ),
    );
  }
}
