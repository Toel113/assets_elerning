import 'package:flutter/material.dart';

class Address extends StatefulWidget{
  const Address({super.key});

  @override
  _Address createState() => _Address();
}

class _Address extends State<Address> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Container(
          child: const Text('Address Page'),
        ),
      ),
    );
  }
}