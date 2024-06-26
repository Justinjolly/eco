import 'package:app/main.dart';
import 'package:app/pages/HomePage.dart';
import 'package:app/pages/datapreview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/pages/balances.dart';
import 'package:app/pages/qr.dart';
import 'package:app/pages/settings.dart';
import 'package:app/pages/emailsettings.dart';
import 'datapreview.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

//this page
class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User? _user;
  String _fullName = '';
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(_user!.uid).get();
      setState(() {
        _fullName = userData['fullName'];
        _phoneNumber = userData['mobileNumber'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'lib/assets/logo2.jpg',
                width: 50.0,
                height: 60.0,
              ),
            ),
            Text(
              'EcoExpence',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async => false, // Prevent pop action
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue, // Customize the color as needed
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 206, 210, 212),
                    radius: 40,
                    backgroundImage: AssetImage(
                        'lib/assets/g.png'), // Adjust the size of the circle avatar as needed
                    child: Text(
                      _user?.displayName != null ? _user!.displayName![0] : "",
                      style: TextStyle(
                        fontSize: 40.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _fullName,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _user?.email ?? "",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _phoneNumber,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ListTile(
            //   leading: Icon(
            //     Icons.qr_code,
            //     size: 30,
            //   ),
            //   title: Text(
            //     'Scan Code',
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            //   onTap: () {
            //     // Navigate to balances page
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => QRScanPage()),
            //     );
            //   },
            // ),
            ListTile(
              leading: Icon(
                Icons.settings,
                size: 30,
              ),
              title: Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Navigate to settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            // ListTile(
            //   leading: Icon(
            //     Icons.notification_add,
            //     size: 30,
            //   ),
            //   title: Text(
            //     'Notification Settings',
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            //   onTap: () {
            //     // Navigate to email settings page
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => EmailSettingsPage()),
            //     );
            //   },
            // ),
            ListTile(
              leading: Icon(
                Icons.graphic_eq,
                size: 30,
              ),
              title: Text(
                'Data Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Navigate to email settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseGraph(userId: _user!.uid)),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                size: 30,
              ),
              title: Text(
                'Logout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                await _auth.signOut(); // Sign out the user
                Navigator.pushReplacement(
                  // Use pushReplacement to replace the current screen
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
