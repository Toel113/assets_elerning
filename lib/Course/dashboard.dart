import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'CoursePage.dart';
import 'package:assets_elerning/Profile/Profile.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;

  const DashboardPage({
    super.key,
    required this.userEmail,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late List<Widget> _children;

  int myIndex = 0;
  @override
  void initState() {
    super.initState();
    _children = [
      CoursePage(
        userEmail: widget.userEmail,
      ),
      ProfilePage(
        userEmail: widget.userEmail,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return IndexedStack(
            index: myIndex,
            children: _children,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myIndex, 
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) async {
          if (index == 2) {
            await GoogleSignIn().signOut();
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            setState(() {
              myIndex = index;
            });
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color.fromARGB(255, 22, 22, 22)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color.fromARGB(255, 20, 20, 20)),
            label: 'Profile',
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

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildDrawerBody(context),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerBody(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            runSpacing: 16,
            children: [
              ListTile(
                title: const Text('Edit Profile'),
                onTap: () {},
              ),
              const SizedBox(height: 25),
              ListTile(
                title: const Text('Membership & Subscription'),
                onTap: () {},
              ),
              const SizedBox(height: 25),
              ListTile(
                title: const Text('Purchase History'),
                onTap: () {},
              ),
              const SizedBox(height: 25),
              ListTile(
                title: const Text('Add/Change Credit Card'),
                onTap: () {},
              ),
              const SizedBox(height: 25),
              ListTile(
                title: const Text('Address'),
                onTap: () {},
              ),
              const SizedBox(height: 25),
              ListTile(
                title: const Text('Contact'),
                onTap: () {},
              ),
              const SizedBox(height: 25),
              ListTile(
                title: const Text('Log Out'),
                onTap: () {},
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      );
}
