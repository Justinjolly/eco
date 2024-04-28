import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendFilter { All, IOwe, OweMe }

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Friend> allFriends = [];
  List<Friend> displayedFriends = [];
  FriendFilter _selectedFilter = FriendFilter.All;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  void fetchFriends() {
  // Fetch the user ID of the logged-in user
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    FirebaseFirestore.instance
        .collection('friends')
        .where('groupName', isEqualTo: currentUser.displayName)
        .get()
        .then((querySnapshot) {
      Set<String> uniqueFriendNames = Set<String>(); // Use a set to store unique friend names
      List<Friend> friends = [];

      querySnapshot.docs.forEach((doc) {
        List<dynamic> members = doc['members'];
        members.forEach((member) {
          if (member != currentUser.displayName && !uniqueFriendNames.contains(member)) {
            uniqueFriendNames.add(member); // Add the friend's name to the set
            friends.add(Friend(name: member, amount: 0.0));
          }
        });
      });

      setState(() {
        allFriends = friends;
        displayedFriends = List.from(allFriends);
      });
    }).catchError((error) {
      print('Failed to fetch friends data from Firestore: $error');
    });
  } else {
    print('User is not logged in. Cannot fetch friends data.');
  }
}

  void filterFriends(String query) {
    setState(() {
      displayedFriends = allFriends
          .where((friend) =>
              friend.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void applyFilter(FriendFilter filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case FriendFilter.All:
          displayedFriends = List.from(allFriends);
          break;
        case FriendFilter.IOwe:
          displayedFriends =
              allFriends.where((friend) => friend.amount < 0).toList();
          break;
        case FriendFilter.OweMe:
          displayedFriends =
              allFriends.where((friend) => friend.amount > 0).toList();
          break;
      }
    });
  }

  void showFilterOptions() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(300.0, 75.0, 0.0, 0.0),
      items: [
        PopupMenuItem<FriendFilter>(
          value: FriendFilter.All,
          child: Text('All'),
        ),
        PopupMenuItem<FriendFilter>(
          value: FriendFilter.IOwe,
          child: Text('I Owe'),
        ),
        PopupMenuItem<FriendFilter>(
          value: FriendFilter.OweMe,
          child: Text('Owe Me'),
        ),
      ],
      elevation: 8.0,
    ).then((filter) {
      if (filter != null) {
        applyFilter(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Friends',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
        centerTitle: true, // Center the title
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
                  onChanged: filterFriends,
                  style: TextStyle(color: Colors.white), // Text color white
                  decoration: InputDecoration(
                    labelText: 'Find Friends',
                    labelStyle:
                        TextStyle(color: Colors.white), // Label color white
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white), // Icon color white
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.sort, size: 24.0, color: Colors.white),
                onPressed: () {
                  // Show sort options
                  showFilterOptions();
                },
              ),
            ],
          ),
          Expanded(
  child: ListView.builder(
    itemCount: displayedFriends.length,
    itemBuilder: (context, index) {
      Friend friend = displayedFriends[index];
      return ListTile(
        title: Text(
          "${friend.name}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0, // Adjust the font size as needed
          ),
        ),
      );
    },
  ),
),

        ],
      ),
    );
  }
}

class Friend {
  final String name;
  final double amount;

  Friend({required this.name, required this.amount});
}
