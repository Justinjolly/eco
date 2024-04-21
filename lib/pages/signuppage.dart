import 'package:app/pages/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:phone_number/phone_number.dart';
import 'dart:convert';
import 'package:random_string/random_string.dart';

class TwilioService {
  static const String twilioAccountSid = 'ACf42193fce66d79c76176fd7f3bd6ec47';
  static const String twilioAuthToken = '72322b3bb9bf164b9cf814f64ead0734';
  static const String twilioPhoneNumber = '+12249932320';

  static Future<String?> sendOTP(String phoneNumber) async {
    try {
      String otp = randomNumeric(4); // Generate a random 4-digit OTP
      final response = await http.post(
        Uri.parse(
            'https://api.twilio.com/2010-04-01/Accounts/$twilioAccountSid/Messages.json'),
        headers: {
          'Authorization': 'Basic ' +
              base64Encode(utf8.encode('$twilioAccountSid:$twilioAuthToken')),
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'To': phoneNumber,
          'From': twilioPhoneNumber,
          'Body': 'Your OTP is: $otp',
          // Include the Service SID in the request
          'ServiceSid': 'VA3a0436933bd8abf205d60fbcc54b7f98',
        },
      );

      if (response.statusCode == 201) {
        // OTP sent successfully
        return otp;
      } else {
        // Error occurred while sending OTP
        return null;
      }
    } catch (e) {
      // Error occurred
      print('Error sending OTP: $e');
      return null;
    }
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isMobileVerified = false;
  bool _isOTPVerified = false;
  bool _isOTPButtonVerified = false; // New variable to track OTP verification

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addUserDataToFirestore(
    String userId,
    String userName,
    String fullName,
    String email,
    String mobileNumber,
    String password,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'userName': userName,
        'fullName': fullName,
        'email': email,
        'mobileNumber': mobileNumber,
        'password': password,
      });
    } catch (e) {
      print('Error adding user data to Firestore: $e');
    }
  }

  void _handleEmailSignUp() async {
    try {
      _startLoading();

      String userName = _userNameController.text;
      String fullName = _fullNameController.text;
      String mobileNumber = _mobileController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      if (userName.isEmpty ||
          fullName.isEmpty ||
          mobileNumber.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        _showErrorPopup('Please fill in all mandatory fields.');
        _stopLoading();
        return;
      }

      bool usernameExists = await _checkUsernameExists(userName);
      if (usernameExists) {
        _showErrorPopup('Username already exists. Please choose another one.');
        _stopLoading();
        return;
      }

      if (!_isMobileVerified) {
        _showErrorPopup('Please verify your mobile number.');
        _stopLoading();
        return;
      }

      if (!_isOTPVerified) {
        _showErrorPopup('Please verify OTP.');
        _stopLoading();
        return;
      }

      _stopLoading();

      _performSignup();
    } catch (e) {
      _stopLoading();
      _showErrorPopup('Error during signup: $e');
    }
  }

  Future<bool> _checkUsernameExists(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: username)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username existence: $e');
      return true;
    }
  }

  Future<bool> _verifyOTP(String otp, String mobileNumber) async {
    // Implement Twilio OTP verification logic here
    // For demonstration, always consider OTP as verified
    return true;
  }

  void _showOTPVerificationPopup(String mobileNumber) async {
    String formattedPhoneNumber = "+91" + mobileNumber;
    String? otp = await TwilioService.sendOTP(formattedPhoneNumber);
    if (otp != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Verify OTP'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  bool otpVerified = await _verifyOTP(
                      _otpController.text, formattedPhoneNumber);
                  if (otpVerified) {
                    Navigator.pop(context);
                    setState(() {
                      _isOTPVerified = true;
                      _isOTPButtonVerified =
                          true; // Set button to verified state
                    });
                  } else {
                    _showErrorPopup('Invalid OTP. Please try again.');
                  }
                },
                child: Text('Verify'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    } else {
      _showErrorPopup('Failed to send OTP. Please try again.');
    }
  }

  void _performSignup() async {
    String userName = _userNameController.text;
    String fullName = _fullNameController.text;
    String mobileNumber = _mobileController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    String phoneNumber = "+91" + mobileNumber;

    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _addUserDataToFirestore(
      userCredential.user!.uid,
      userName,
      fullName,
      email,
      phoneNumber,
      password,
    );

    _navigateToLoginPage();
  }

  void _navigateToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create an Account',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      labelText: 'User Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _mobileController,
                          onChanged: (value) {
                            setState(() {
                              _isMobileVerified = value.length == 10;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.phone, color: Colors.blue[700]),
                          ),
                        ),
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: _isMobileVerified && !_isOTPButtonVerified
                              ? () => _showOTPVerificationPopup(
                                  _mobileController.text)
                              : null,
                          child: Text('Verify'),
                          style: ElevatedButton.styleFrom(
                            // Change background color based on verification state
                            backgroundColor: _isOTPButtonVerified
                                ? Colors.lightGreen
                                : Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleEmailSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
