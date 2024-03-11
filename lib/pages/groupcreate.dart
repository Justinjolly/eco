import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
              onPressed: () async {
                String groupName = groupNameController.text;
                String groupType = groupTypeController.text;

                if (groupName.isNotEmpty && groupType.isNotEmpty) {
                  // Check if the group name already exists
                  bool groupExists =
                      await _checkGroupExists(groupName, context);
                  if (groupExists) {
                    _showRenameDialog(context, groupName);
                  } else {
                    // Create a new document in the "groups" collection with the provided data
                    DocumentReference groupRef = await FirebaseFirestore
                        .instance
                        .collection('groups')
                        .add({
                      'groupName': groupName,
                      'groupType': groupType,
                    });
                    String groupId =
                        groupRef.id; // Get the ID of the newly created group
                    print('Group created successfully! Group ID: $groupId');

                    // Navigate to AddFriendPage and pass the group ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFriendPage(groupId: groupId),
                      ),
                    );
                  }
                } else {
                  _showAlertDialog(
                      context); // Show alert dialog if fields are empty
                }
              },
              child:
                  Text('Create Group', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the home page when the back button is pressed
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child:
                  Text('Back to Home', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
