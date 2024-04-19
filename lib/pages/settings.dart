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

  late TextEditingController nameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController phoneController = TextEditingController();
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
        nameController.text = userData['fullName'] ?? 'N/A';
        emailController.text = user.email ?? 'N/A';
        phoneController.text = userData['mobileNumber'] ?? 'N/A';
      });
    } else {
      nameController.text = 'N/A';
      emailController.text = 'N/A';
      phoneController.text = 'N/A';
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
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
              enabled: false,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter new password',
                suffixIcon: Icon(Icons.edit),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
              ),
              enabled: false, // This disables the text field
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = _auth.currentUser;
                if (user != null) {
                  if (passwordController.text.isNotEmpty) {
                    try {
                      await user.updatePassword(passwordController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Password Updated Successfully'))
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update password: $e'))
                      );
                    }
                  }
                  try {
                    await _firestore.collection('users').doc(user.uid).update({
                      'fullName': nameController.text,
                      'mobileNumber': phoneController.text,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile Updated Successfully'))
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update profile: $e'))
                    );
                  }
                } else {
                  print('User not logged in');
                }
              },
              child: Text('Save Changes'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Provider.of<ThemeManager>(context, listen: false).toggleTheme();
            //   },
            //   child: Text('Dark Theme'),
            // ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                User? user = _auth.currentUser;
                if (user != null) {
                  try {
                    await _firestore.collection('users').doc(user.uid).delete();
                    await user.delete();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Account deleted successfully'))
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete account: $e'))
                    );
                  }
                }
              },
              child: Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
