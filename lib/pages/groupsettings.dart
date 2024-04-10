import 'package:flutter/material.dart';
import 'package:app/pages/friendsettings.dart';
import 'package:app/pages/groupsettingsedit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GroupSettingsPage(groupName: 'Your Group Name'),
    );
  }
}

class GroupSettingsPage extends StatelessWidget {
  final String groupName;
  final List<Map<String, String>> groupMembers = [
    {'name': 'Adwaith', 'email': 'alice@example.com', 'amount': '\$20'},
    {'name': 'Dony', 'email': 'bob@example.com', 'amount': '\$20'},
    {'name': 'Jibbin', 'email': 'charlie@example.com', 'amount': '\$20'},
    {'name': 'Justin', 'email': 'dana@example.com', 'amount': '\$20'},
  ];

  GroupSettingsPage({required this.groupName});

  @override
  Widget build(BuildContext context) {
    double totalAmount = groupMembers.fold(0, (previousValue, element) {
      return previousValue +
          double.parse(element['amount']!.replaceAll('\$', ''));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Group Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '🏝️',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$groupName',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomizeGroupPage()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Group Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: () {
                    // Your code to add people to the group
                  },
                ),
                Text('Add Group Members'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.link, size: 30),
                  color: const Color.fromARGB(255, 234, 234, 234),
                  onPressed: () {
                    // Your code to share invite link
                  },
                ),
                Text('Invite via Link',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 234, 231, 231))),
              ],
            ),
            SizedBox(height: 20),
            ...groupMembers.map((member) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(member['name']![0],
                          style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member['name']!, style: TextStyle(fontSize: 18)),
                          Text(member['email']!,
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(member['amount']!, style: TextStyle(fontSize: 18)),
                  ],
                ),
              );
            }).toList(),
            Spacer(),
            InkWell(
              onTap: () {
                // Handle leave group action
              },
              child: Row(
                children: [
                  Icon(Icons.exit_to_app,
                      color: const Color.fromARGB(255, 218, 215, 215)),
                  SizedBox(width: 8),
                  Text('Leave Group',
                      style: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 224, 214, 214))),
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
