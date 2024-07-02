import 'package:flutter/material.dart';

class sellPage extends StatefulWidget {
  const sellPage({super.key});

  @override
  _sellPage createState() => _sellPage();
}

class _sellPage extends State<sellPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text(''),
      ),
      body: Center(
        child: Container(
          child: const Text('Sell Page'),
        ),
      ),
    );
  }
}
