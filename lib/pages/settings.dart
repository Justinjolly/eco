import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController nameController = TextEditingController(text: 'John Doe');
  TextEditingController emailController = TextEditingController(text: 'john.doe@example.com');
  TextEditingController phoneController = TextEditingController(text: '1234567891');
  TextEditingController passwordController = TextEditingController(text: 'password123');
  
  
  // get phoneController => null;

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
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
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
