import 'package:app/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/pages/SignUpPage.dart';
import 'package:app/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/pages/forgotpassword.dart'; // Import the new page

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

Future<void> addSession(String userId, String email) async {
  try {
    // Generate a unique session ID (you can use UUID or any other method)
    String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    // Create a new session document in the sessions collection
    await FirebaseFirestore.instance.collection('sessions').doc(sessionId).set({
      'userId': userId,
      'email': email,
      'loginTimestamp': FieldValue.serverTimestamp(), // Store server timestamp
      // Add any additional fields you need
    });
  } catch (error) {
    // Handle errors
    print('Error adding session: $error');
  }
}

Future<void> createSession(User user) async {
  try {
    // Get a reference to the Firestore collection
    CollectionReference sessions =
        FirebaseFirestore.instance.collection('sessions');

    // Check if the 'sessions' collection exists
    var sessionsSnapshot = await sessions.get();
    if (sessionsSnapshot.docs.isEmpty) {
      // 'sessions' collection does not exist, create it
      await sessions.add({});
      print('Created sessions collection');
    }

    // Create a new document for the user session
    await sessions.doc(user.uid).set({
      'email': user.email,
      'lastLogin': DateTime.now(), // Timestamp of the last login
      // Add any other user session data you want to store
    });

    print('Session created successfully for user: ${user.uid}');
  } catch (e) {
    print('Error creating session: $e');
    // Handle any errors that occur during session creation
  }
}

Future<bool> _checkActiveSession(String email) async {
  try {
    // Query the sessions collection to check for active sessions
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('sessions')
        .where('email', isEqualTo: email)
        .get();

    // Check if any active sessions exist for the provided email
    return querySnapshot.docs.isNotEmpty;
  } catch (error) {
    // Handle any errors that occur during the query
    print('Error checking active session: $error');
    return false; // Return false in case of error
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoggingIn = false; // Track whether login process is in progress
  bool _isPasswordVisible = false;

  void _handleEmailSignIn() async {
    setState(() {
      _isLoggingIn = true; // Start the login animation
    });

    try {
      // Check if the user already has an active session
      bool hasActiveSession = await _checkActiveSession(_emailController.text);

      if (hasActiveSession) {
        // Handle case where user already has an active session
        setState(() {
          _errorMessage = 'You are already logged in from another device.';
          _isLoggingIn = false; // Stop the login animation
        });
        return;
      }

      // Proceed with login if no active session found
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Handle successful login
      print('User logged in: ${userCredential.user!.uid}');

      // Create session for the user
      await addSession(userCredential.user!.uid, userCredential.user!.email!);

      // Navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationBarExample()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors
      setState(() {
        _errorMessage = 'Invalid credentials. Please try again.';
        _isLoggingIn = false; // Stop the login animation
      });
      print('Error during login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color.fromARGB(251, 7, 233, 233),
              Color.fromARGB(251, 38, 39, 39),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LOGIN',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255)),
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 239, 239, 239),
                    ),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      suffixIcon: IconButton(
                        onPressed: () {
                          // Toggle password visibility
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoggingIn ? null : _handleEmailSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 25, 9, 128),
                    minimumSize: Size(500, 50),
                  ),
                  child: _isLoggingIn
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors
                              .white)) // Show loading indicator if logging in
                      : Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
                SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
