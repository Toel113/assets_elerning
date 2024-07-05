import 'package:assets_elerning/api/loadImages.dart';
import 'package:assets_elerning/loginadnsigupPage.dart/login.dart';
import 'package:flutter/material.dart';
import 'CoursePage.dart';
import 'package:assets_elerning/Profile/Profile.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;
  final String userPassword;

  const DashboardPage(
      {super.key, required this.userEmail, required this.userPassword});

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
          userEmail: widget.userEmail, userPassword: widget.userPassword),
      ProfilePage(
          UserEmail: widget.userEmail, UserPassword: widget.userPassword),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myIndex != 2
          ? AppBar(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              automaticallyImplyLeading: false,
              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DashboardPage(
                            userEmail: widget.userEmail,
                            userPassword: widget.userPassword)),
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
      drawer: const NavigationDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return IndexedStack(
            index: myIndex,
            children: _children,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myIndex, // Set the current index
        selectedItemColor: const Color.fromARGB(255, 24, 24, 24),
        unselectedItemColor: Colors.grey,
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
