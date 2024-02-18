import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/pages/addfriend.dart';

class GroupCreate extends StatelessWidget {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Members'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Disable the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: groupTypeController,
              decoration: InputDecoration(
                labelText: 'Group Type',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String groupName = groupNameController.text;
                String groupType = groupTypeController.text;

                if (groupName.isNotEmpty && groupType.isNotEmpty) {
                  // Create a new document in the "groups" collection with the provided data
                  FirebaseFirestore.instance.collection('groups').add({
                    'groupName': groupName,
                    'groupType': groupType,
                  }).then((_) {
                    print('Group created successfully!');
                    // Optionally, navigate to a different page after creating the group
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFriendPage(),
                      ),
                    );
                  }).catchError((error) {
                    print('Error creating group: $error');
                  });
                } else {
                  _showAlertDialog(
                      context); // Show alert dialog if fields are empty
                }
              },
              child:
                  Text('Create Group', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
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
}
