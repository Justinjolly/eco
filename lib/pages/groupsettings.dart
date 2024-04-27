import 'package:app/pages/friendsettings.dart';
import 'package:app/pages/groupsettingsedit.dart';
import 'package:app/pages/homepage.dart';
import 'package:app/pages/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addfriend.dart'; // Import the addfriend.dart file

class GroupSettingsPage extends StatefulWidget {
  final String groupName;
  final List<Map<String, String>> groupMembers;
  final String currentUsername; // Remove example data

  GroupSettingsPage(
      {required this.groupName,
      required this.groupMembers,
      required this.currentUsername});

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

Future<String?> getUserIdFromUsername(String username) async {
  try {
    // Query Firestore to find the document where 'userName' field matches the provided username
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isEqualTo: username)
        .limit(1) // Limit to only one document (assuming usernames are unique)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If there's a matching document, return the user ID
      return querySnapshot.docs.first.id;
    } else {
      // If no matching document is found, return null
      return null;
    }
  } catch (error) {
    // Handle any errors that occur during the query
    print('Error getting user ID from username: $error');
    return null;
  }
}

void _deleteGroup(BuildContext context, String groupId) async {
  try {
    // Reference to the group document in Firestore
    DocumentReference groupDocRef =
        FirebaseFirestore.instance.collection('groups').doc(groupId);
    // Delete the group document
    await groupDocRef.delete();
    // Navigate to the home page
    Navigator.popUntil(context, ModalRoute.withName('/'));
  } catch (e) {
    // Handle any errors that occur during deletion
    print('Error deleting group: $e');
    // Show a snackbar or dialog to inform the user about the error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to delete group. Please try again later.'),
      ),
    );
  }
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('groups');
    return StreamBuilder<QuerySnapshot>(
      stream: collectionRef
          .where('groupName', isEqualTo: widget.groupName)
          .snapshots(), // Replace 'currentUserID' with the actual user ID
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
          double totalAmount =
              widget.groupMembers.fold(0, (previousValue, element) {
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
                          '${widget.groupName}',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}', // Display total amount
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 1, color: Colors.grey), // Add a divider

                  Text(
                    'Members List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  Divider(thickness: 1, color: Colors.grey), // Add a divider
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                            snapshot.data!.docs[index];
                        List<dynamic> members = documentSnapshot[
                            'members']; // Access all members from the snapshot
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: members.map((member) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 17,
                                  child: Text(
                                    member[
                                        0], // Access the first character of the member's name
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Color.fromARGB(255, 92, 214,
                                      61), // Change color as needed
                                ),
                                title: Text(
                                  member,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  // Add onTap functionality here if needed
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: () async {
                          // Fetch the group ID from Firestore
                          String groupId = snapshot.data!.docs.first
                              .id; // Assuming the first document contains the group ID

                          // Fetch the user ID of the group creator from the Firestore document
                          String userId = snapshot.data!.docs.first[
                              'creator']; // Assuming 'creator' is the field storing the user ID

                          // Navigate to AddFriendPage with both groupId and userId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddFriendPage(
                                  groupId: groupId, userId: userId),
                            ),
                          );
                        },
                      ),
                      Text('Add Group Members'),
                    ],
                  ),

                  ...widget.groupMembers.map((member) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: Text(member['name']![0],
                                style: TextStyle(
                                    color:
                                        Colors.black)), // First letter of name
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
                                                              memberDetails:
                                                                  member),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'View settings for ${member['name']}',
                                                  style:
                                                      TextStyle(fontSize: 18),
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
                          Text(member['amount']!,
                              style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    );
                  }).toList(),
                  Spacer(),
                  InkWell(
                    onTap: () async {
                      // Fetch the group ID from Firestore
                      String groupId = snapshot.data!.docs.first.id;

                      // Fetch the user ID of the group creator from the Firestore document
                      String groupCreatorId =
                          snapshot.data!.docs.first['creator'];

                      // Check if the current user is the group creator
                      bool isGroupCreator = groupCreatorId ==
                          FirebaseAuth.instance.currentUser!.uid;

                      // Display a confirmation dialog before leaving the group
                      bool leaveConfirmation = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Leave Group'),
                            content: Text(
                                'Are you sure you want to leave the group?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(
                                      false); // Return false if the user cancels
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(
                                      true); // Return true if the user confirms
                                },
                                child: Text('Leave'),
                              ),
                            ],
                          );
                        },
                      );

                      // If user confirms leaving the group
                      if (leaveConfirmation == true) {
                        // Reference to the Firestore document
                        DocumentReference groupDocRef =
                            collectionRef.doc(groupId);

                        // Update the Firestore document with the modified 'members' array
                        List<String> updatedMembers = List<String>.from(
                            snapshot.data!.docs.first['members']);
                        if (isGroupCreator) {
                          // If the current user is the group creator
                          updatedMembers.remove(widget
                              .currentUsername); // Remove current user from members list
                          if (updatedMembers.isNotEmpty) {
                            // If there are other members in the group, fetch the user ID of the next member (new creator)
                            String newCreatorUsername = updatedMembers.first;
                            DocumentSnapshot userSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(newCreatorUsername)
                                    .get();
                            String newCreatorId = userSnapshot
                                .id; // Get the user ID of the new creator
                            String? userId =
                                await getUserIdFromUsername(newCreatorId);
                            print(userId);
                            await groupDocRef.update({
                              'creator':
                                  userId, // Set the new creator's user ID as the creator
                              'members':
                                  updatedMembers, // Update the members list
                            });
                          } else {
                            // If there are no other members in the group, clear the creator field
                            await groupDocRef.update({
                              'creator': '', // Clear the creator ID
                              'members':
                                  updatedMembers, // Update the members list (empty)
                            });
                          }
                        } else {
                          // If the current user is not the group creator, just remove the current user
                          updatedMembers.remove(widget.currentUsername);
                          await groupDocRef.update({
                            'members':
                                updatedMembers, // Update the members list
                          });
                        }
                        // Navigate to a different page or perform any other action after leaving the group
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app,
                            color: const Color.fromARGB(255, 240, 239, 239)),
                        SizedBox(width: 8),
                        Text('Leave Group',
                            style: TextStyle(
                                fontSize: 18,
                                color:
                                    const Color.fromARGB(255, 220, 213, 213))),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      // Call the method to delete the group document
                      _deleteGroup(context, snapshot.data!.docs.first.id);
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
