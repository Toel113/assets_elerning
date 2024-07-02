import 'package:flutter/material.dart';

class Add_chang_CreditCard extends StatefulWidget{
  const Add_chang_CreditCard({super.key});

  @override
  _Add_chang_Creditcard createState() => _Add_chang_Creditcard();

}

class _Add_chang_Creditcard extends State<Add_chang_CreditCard>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Container(
          child: const Text('Add Chang Credit Card'),
        ),
      ),
    );
  }
}