import 'package:flutter/material.dart';
import 'package:app/pages/friendsettings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GroupSettingsPage(
        groupName: 'Group Name',
        groupMembers: ['Member 1', 'Member 2', 'Member 3'],
      ),
    );
  }
}

class GroupSettingsPage extends StatelessWidget {
  final String groupName;
  final List<String> groupMembers;

  GroupSettingsPage({required this.groupName, required this.groupMembers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Group Name: $groupName',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Group Members:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: groupMembers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(groupMembers[index].substring(0, 1),
                          style: TextStyle(color: Colors.black)),
                    ),
                    title: Text(groupMembers[index]),
                    onTap: () {
                      // Navigate to friend settings page when a member is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendSettingsPage(
                            memberDetails: {
                              'name': groupMembers[index],
                              'email':
                                  'example@example.com', // Provide dummy email for now
                              'amount':
                                  '\$0.00', // Provide dummy amount for now
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                // Handle leave group action
              },
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Leave Group',
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                ],
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () {
                // Handle delete group action
              },
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Group',
                      style: TextStyle(fontSize: 18, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
