import 'package:flutter/material.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  _MembershipPage createState() => _MembershipPage();
}

class _MembershipPage extends State<MembershipPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Container(
          child: const Text('Membership Page'),
        ),
      ),
    );
  }
}