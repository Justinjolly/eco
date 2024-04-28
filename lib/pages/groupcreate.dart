import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'addfriend.dart'; // Import AddFriendPage if not already imported

class GroupCreate extends StatelessWidget {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupTypeController = TextEditingController();

  Future<bool> _checkGroupExists(String groupName, BuildContext context) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('groupName', isEqualTo: groupName)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _showRenameDialog(BuildContext context, String groupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Group Name Exists'),
          content: Text(
              'A group with the name "$groupName" already exists. Please enter a different name.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Please fill in all required fields.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
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
        title: Text(
          'Create Group',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Disable the back button
        backgroundColor: Colors.blue, // Updated app bar color
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Group Information',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 221, 218, 218),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: groupNameController,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 246, 246, 246)),
                        decoration: InputDecoration(
                          labelText: 'Group Name',
                          labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 255, 254, 254)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: groupTypeController,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 247, 246, 246)),
                        decoration: InputDecoration(
                          labelText: 'Group Type',
                          labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 229, 225, 225)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              String groupName = groupNameController.text;
                              String groupType = groupTypeController.text;
                              String userId =
                                  FirebaseAuth.instance.currentUser?.uid ?? '';

                              if (groupName.isNotEmpty &&
                                  groupType.isNotEmpty &&
                                  userId.isNotEmpty) {
                                bool groupExists =
                                    await _checkGroupExists(groupName, context);
                                if (groupExists) {
                                  _showRenameDialog(context, groupName);
                                } else {
                                  DateTime now = DateTime.now();
                                  String formattedDate =
                                      '${now.day}-${now.month}-${now.year}';

                                  DocumentReference groupRef =
                                      await FirebaseFirestore.instance
                                          .collection('groups')
                                          .add({
                                    'groupName': groupName,
                                    'groupType': groupType,
                                    'creator': userId,
                                    'creationDate': formattedDate,
                                  });
                                  String groupId = groupRef.id;
                                  print(
                                      'Group created successfully! Group ID: $groupId');

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddFriendPage(
                                          groupId: groupId, userId: userId),
                                    ),
                                  );
                                }
                              } else {
                                _showAlertDialog(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Button color
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Create Group',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey, // Button color
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Back to Home',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
