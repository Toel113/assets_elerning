import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuth extends StatefulWidget {
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Authentication")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _auth.verifyPhoneNumber(
                  phoneNumber: _phoneController.text,
                  verificationCompleted:
                      (PhoneAuthCredential credential) async {
                    await _auth.signInWithCredential(credential);
                  },
                  verificationFailed: (FirebaseAuthException e) {
                    print('Verification failed: ${e.message}');
                  },
                  codeSent: (String verificationId, int? resendToken) {
                    setState(() {
                      _verificationId = verificationId;
                    });
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {
                    setState(() {
                      _verificationId = verificationId;
                    });
                  },
                );
              },
              child: Text("Verify Phone Number"),
            ),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: "Verification Code"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final code = _codeController.text.trim();
                if (_verificationId != null) {
                  final credential = PhoneAuthProvider.credential(
                    verificationId: _verificationId!,
                    smsCode: code,
                  );
                  await _auth.signInWithCredential(credential);
                }
              },
              child: Text("Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}
