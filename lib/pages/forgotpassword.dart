import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginpage.dart';

class ForgotPasswordPage extends StatelessWidget {
  TextEditingController _emailController = TextEditingController();

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    try {
      String enteredEmail = _emailController.text;
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: enteredEmail,
      );

      // Show a SnackBar with the success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $enteredEmail'),
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate back to login page after sending reset email
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Handle errors
      print('Error sending password reset email: $e');
      // Display an error message to the user, if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending password reset email: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email to reset password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendPasswordResetEmail(context),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                minimumSize: Size(500, 50),
              ),
              child: Text(
                'Reset Password',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
