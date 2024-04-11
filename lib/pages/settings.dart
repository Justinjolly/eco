import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'thememanager.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  // Assuming password isn't fetched for security reasons
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    DocumentSnapshot userData;
    if (user != null) {
      userData = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        nameController = TextEditingController(text: userData['fullName'] ?? 'N/A');
        emailController = TextEditingController(text: user.email ?? 'N/A');
        phoneController = TextEditingController(text: userData['mobileNumber'] ?? 'N/A');
        // Password field remains untouched or you can set a dummy value
      });
    } else {
      // Default values if user data is not found
      nameController = TextEditingController(text: 'N/A');
      emailController = TextEditingController(text: 'N/A');
      phoneController = TextEditingController(text: 'N/A');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                suffixIcon: Icon(Icons.edit),
              ),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                suffixIcon: Icon(Icons.edit),
              ),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                suffixIcon: Icon(Icons.edit),
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: Icon(Icons.edit),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement saving functionality
                print('Save Changes');
              },
              child: Text('Save Changes'),
            ),
            ElevatedButton(
              onPressed: () {
                // Toggle theme
                Provider.of<ThemeManager>(context, listen: false).toggleTheme();
              },
              child: Text('Dark Theme'),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Implement delete account functionality
                print('Delete Account');
              },
              child: Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
