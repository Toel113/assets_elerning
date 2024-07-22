import 'package:assets_elerning/otp_verification/reset_pass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class submitOTPScreen extends StatefulWidget {
  final String verificationID;

  submitOTPScreen({required this.verificationID});

  @override
  _submitOTPScreen createState() => _submitOTPScreen();
}

class _submitOTPScreen extends State<submitOTPScreen> {
  TextEditingController _otpVerification = TextEditingController();

  Future<void> _summitPhonenumber(BuildContext context) async {
    String OTP = _otpVerification.text.trim();
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationID, smsCode: OTP);
      await auth.signInWithCredential(credential);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ResetPass()));
    } catch (e) {
      print(e.toString());
    }
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
                controller: _otpVerification,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    labelText: "OTP"),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  'Submit',
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
