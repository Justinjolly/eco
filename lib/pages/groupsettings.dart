import 'package:app/pages/friendsettings.dart';
import 'package:app/pages/groupsettingsedit.dart';
import 'package:flutter/material.dart';

// Assume you have a function to fetch group members from the database
Future<List<Map<String, String>>> fetchGroupMembers(String groupName) async {
  // Logic to fetch group members based on groupName from your database
  // Example: Firestore, SQLite, API call, etc.
  // Replace this with your actual implementation
  
  // For demonstration purposes, let's assume a sample list of group members
  return [
    {'name': 'John Doe', 'email': 'john@example.com', 'amount': '100'},
    {'name': 'Jane Smith', 'email': 'jane@example.com', 'amount': '50'},
    // Add more members as needed
  ];
}

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

class GroupSettingsPage extends StatefulWidget {
  final String groupName;

  GroupSettingsPage({required this.groupName});

  @override
  _GroupSettingsPageState createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  late Future<List<Map<String, String>>> _groupMembersFuture;

  @override
  void initState() {
    super.initState();
    _groupMembersFuture = fetchGroupMembers(widget.groupName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _groupMembersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, String>> groupMembers = snapshot.data!;
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
                          '${widget.groupName}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Your code to handle edit action
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
                  SizedBox(height: 10),
                  ...groupMembers.map((member) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: Text(member['name']![0],
                                style: TextStyle(
                                    color: Colors.black)), // First letter of name
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          padding: EdgeInsets.all(16),
                                          height: 120,
                                          child: Row(
                                            children: [
                                              Icon(Icons.person, size: 40),
                                              SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(
                                                      context); // Close the bottom sheet
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FriendSettingsPage(
                                                              memberDetails: member),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'View settings for ${member['name']}',
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(member['name']!,
                                      style: TextStyle(fontSize: 18)),
                                ),
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
      },
    );
  }
}
