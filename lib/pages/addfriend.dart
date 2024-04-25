import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/pages/homepage.dart'; // Import the HomePage widget
import 'package:firebase_auth/firebase_auth.dart';

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


@override
void initState() {
  super.initState();
  _fetchUserData();
}

void _fetchUserData() {
  FirebaseFirestore.instance.collection('users').get().then((querySnapshot) {
    setState(() {
      allUsers = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Check if 'userName' field is not null before adding it to the list
        if (data['userName'] != null) {
          return data['userName'] as String;
        } else {
          return ''; // Return empty string for null values
        }
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

void addToFriends(String groupId) {
  // Fetch the user ID of the logged-in user
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get()
        .then((userData) {
      String userName = userData.data()?['userName'] ?? '';
      if (userName.isNotEmpty) {
        print('Added $userName to friends');
        // Add the current signed-in user to the selected users
        

        // Add all selected users to the group
        FirebaseFirestore.instance.collection('groups').doc(groupId).update({
          'members': FieldValue.arrayUnion(selectedUsers.toList())
        }).then((_) {
          // Store the group name and members in the 'friends' collection
          FirebaseFirestore.instance.collection('friends').add({
            'creatorName': userName,
            'members': selectedUsers.toList()
          }).then((_) {
            print('Users added to the friends collection successfully');
            // Clear the selected users list
            selectedUsers.clear();
          }).catchError((error) {
            print('Error adding users to the friends collection: $error');
          });
        }).catchError((error) {
          print('Error adding users to the group: $error');
        });
      } else {
        print('Failed to fetch username for user ID: ${currentUser.uid}');
      }
    }).catchError((error) {
      print('Error fetching user data: $error');
    });
  } else {
    print('User is not logged in. Cannot add user to the group.');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Add Friend',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
                addToFriends(widget.groupId);
                // Add selected users to the group
                // Add selected users to the group
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
                print('Creating group...');
              },
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
