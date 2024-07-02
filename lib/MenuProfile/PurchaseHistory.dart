import 'package:flutter/material.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  _PurchasePage createState() => _PurchasePage();

}

class _PurchasePage extends State<PurchasePage> {
  @override 

  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Container(
          child: const Text('Purchase Page'),
        ),
      ),
    );
  }
}