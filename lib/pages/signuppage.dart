import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'loginpage.dart';

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
  bool _isLoading = false;

  // Define a Firestore instance
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

  // Method to add user data to Firestore
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
        'userName' : userName,
        'fullName': fullName,
        'email': email,
        'mobileNumber': mobileNumber,
        'password': password,
      });
    } catch (e) {
      // Handle error while adding user data to Firestore
      print('Error adding user data to Firestore: $e');
    }
  }

  void _handleEmailSignUp() async {
    try {
      // Start loading
      _startLoading();

      // Perform signup logic here
      String userName = _userNameController.text;
      String fullName = _fullNameController.text;
      String mobileNumber = _mobileController.text;
      String email = _emailController.text;
      String password = _passwordController.text;


      // Validate input fields (you can add more sophisticated validation)
      if (userName.isEmpty||
          fullName.isEmpty ||
          mobileNumber.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        // Show an error popup if any mandatory field is empty
        _showErrorPopup('Please fill in all mandatory fields.');
        _stopLoading();
        return;
      }

      // Use Firebase Authentication for signup
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await _addUserDataToFirestore(
        userCredential.user!.uid,
        userName,
        fullName,
        email,
        mobileNumber,
        password,
      );

      // Stop loading
      _stopLoading();

      // Continue with signup logic (for now, navigate to the login page)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Stop loading
      _stopLoading();

      // Handle signup errors
      _showErrorPopup('Error during signup: $e');
    }
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
                  TextField(
                    controller: _mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone, color: Colors.blue[700]),
                    ),
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
                      primary: Colors.blue[700],
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
