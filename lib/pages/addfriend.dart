import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/pages/homepage.dart'; // Import the HomePage widget
import 'groupcreate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AddFriendPage extends StatefulWidget {
  final String groupId; // Group ID parameter
  final String userId;

  AddFriendPage({
    required this.groupId,
    required this.userId,
  }); // Constructor to receive group ID

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  List<String> allUsers = [];
  List<String> displayedUsers = [];
  Set<String> selectedUsers = Set();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _initializeLocalNotifications();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _fetchUserData() {
    FirebaseFirestore.instance.collection('users').get().then((querySnapshot) {
      setState(() {
        allUsers = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['userName'] != null ? data['userName'] as String : '';
        }).toList();
        displayedUsers = List.from(allUsers);
      });
    }).catchError((error) {
      print('Failed to fetch user data from Firestore: $error');
    });
  }

  void filterUsers(String query) {
    setState(() {
      displayedUsers = allUsers
          .where((user) => user.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void toggleSelectedUser(String user) {
    setState(() {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
    });
  }

  void addToFriends() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
            'members': FieldValue.arrayUnion(selectedUsers.toList())
          })
          .then((_) {
            showCreationSuccessDialog();
          })
          .catchError((error) {
            print('Error adding users to the group: $error');
          });
    } else {
      print('User is not logged in. Cannot add user to the group.');
    }
  }

Future<void> _showgroupNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Group created',
      'New group has been created',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      "Group created",
      'New group has been created',
      platformChannelSpecifics,
    );
  }

  void showCreationSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Do you want to create this Group."),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                _showgroupNotification();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  ModalRoute.withName('/')
                );
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Add Friend'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 66, 66, 66),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Color.fromARGB(255, 86, 86, 86),
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  onChanged: filterUsers,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Find Friends',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedUsers.length,
              itemBuilder: (context, index) {
                String user = displayedUsers[index];
                bool isSelected = selectedUsers.contains(user);
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: isSelected
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.circle, color: Colors.white),
                        onPressed: () {
                          toggleSelectedUser(user);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                addToFriends();
              },
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
