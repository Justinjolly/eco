import 'package:app/pages/friendsettings.dart';
import 'package:app/pages/groupsettingsedit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class GroupSettingsPage extends StatefulWidget {
  final String groupName;
  final List<Map<String, String>> groupMembers; // Remove example data

  

  GroupSettingsPage({required this.groupName, required this.groupMembers});

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  @override
  Widget build(BuildContext context) {
     final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('groups');
    return StreamBuilder<QuerySnapshot>(
      stream: collectionRef.where('groupName', isEqualTo: widget.groupName).snapshots(), // Replace 'currentUserID' with the actual user ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While data is loading
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurs
          return Text('Error: ${snapshot.error}');
        } else {
          // When data is loaded successfully
          // final userData = snapshot.data!.data() as Map<String, dynamic>;
          // final username = userData['userName'] as String;

          print(snapshot.data);

          // Calculate total amount
          double totalAmount = widget.groupMembers.fold(0, (previousValue, element) {
            return previousValue + double.parse(element['amount']!.replaceAll('\$', ''));
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
                          '${widget.groupName}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}', // Display total amount
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Group Members',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                       DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
      List<dynamic> members = documentSnapshot['members']; // Access all members from the snapshot
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: members.map((member) {
          return Container(
            child: Text(member),
          );
        }).toList(),
      );
                      
                    }),
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
                  ...widget.groupMembers.map((member) {
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
