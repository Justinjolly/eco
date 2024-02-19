import 'package:app/pages/group.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(), // Set the theme to dark
      home: AddFriendPage(),
    );
  }
}

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  List<String> allUsers = []; // You can fetch users from an API or other sources

  List<String> displayedUsers = [];

  @override
  void initState() {
    super.initState();
    // For demonstration purposes, adding some example users
    allUsers = [
      "John Doe",
      "Jane Smith",
      "Alice Johnson",
      "Bob Brown",
      "Charlie Davis",
      "David Wilson",
      // Add more users as needed
    ];
    displayedUsers = List.from(allUsers);
  }

  void filterUsers(String query) {
    setState(() {
      displayedUsers = allUsers
          .where((user) => user.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addToFriends(String user) {
    // Implement the logic to add the user to friends
    // For demonstration purposes, you can print a message
    print('Added $user to friends');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Friend',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
        centerTitle: true, // Center the title
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
                color: Color.fromARGB(255, 66, 66, 66), // Dark background color
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
                  style: TextStyle(color: Colors.white), // Text color white
                  decoration: InputDecoration(
                    labelText: 'Find Friends',
                    labelStyle: TextStyle(color: Colors.white), // Label color white
                    prefixIcon: Icon(Icons.search, color: Colors.white), // Icon color white
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
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0, // Adjust the font size as needed
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.person_add, color: Colors.white),
                        onPressed: () {
                          addToFriends(user);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>ChatScreen()
                  ),
                );
                // Add logic to create a group
                print('Creating group...');
              },
              child: Text('Create Group'),
            ),
          ),
        ],
      ),
    );
  }
}
