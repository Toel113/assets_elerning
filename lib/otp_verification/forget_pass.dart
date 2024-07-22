import 'package:assets_elerning/otp_verification/submit_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class sendOTPPageState extends StatefulWidget {
  @override
  _sendOTPPageState createState() => _sendOTPPageState();
}

class _sendOTPPageState extends State<sendOTPPageState> {
  TextEditingController _phonenumber = TextEditingController();

  Future<void> _summitPhonenumber(BuildContext context) async {
    String phoneNumber = _phonenumber.text.trim();
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credentail) async {},
        verificationFailed: (FirebaseAuthException e) {
          print(e.message.toString());
        },
        codeSent: (String verificationID, int? resendToken) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => submitOTPScreen(
                        verificationID: verificationID,
                      )));
        },
        codeAutoRetrievalTimeout: (String verificationID) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 70,
            ),
            Center(
              child: Text(
                'Send OTP',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _phonenumber,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    labelText: "Phon number"),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            InkWell(
              onTap: () {
                _summitPhonenumber(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  'Send OTP',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
