import 'package:flutter/material.dart';

class Contant extends StatefulWidget {
  const Contant({super.key});

  @override
  _Contant createState() => _Contant();
}

class _Contant extends State<Contant> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Container(
          child: const Text('Contant Page'),
        ),
      ),
    );
  }
}