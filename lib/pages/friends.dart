import 'package:flutter/material.dart';
enum FriendFilter { All, IOwe, OweMe }

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Friend> allFriends = [
    Friend(name: "John", amount: -50.0),
    Friend(name: "Jane", amount: 30.0),
    Friend(name: "Alice", amount: -20.0),
    Friend(name: "Bob", amount: 10.0),
    Friend(name: "Charlie", amount: 0.0),
    Friend(name: "David", amount: 15.0),
    // Add more friends as needed
  ];

  List<Friend> displayedFriends = [];

  FriendFilter _selectedFilter = FriendFilter.All;

  @override
  void initState() {
    super.initState();
    displayedFriends = List.from(allFriends);
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
          displayedFriends = allFriends.where((friend) => friend.amount < 0).toList();
          break;
        case FriendFilter.OweMe:
          displayedFriends = allFriends.where((friend) => friend.amount > 0).toList();
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
        title: Text(
          'Friends',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
        centerTitle: true, // Center the title
        automaticallyImplyLeading: false,
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
                    labelStyle: TextStyle(color: Colors.white), // Label color white
                    prefixIcon: Icon(Icons.search, color: Colors.white), // Icon color white
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
                IconData iconData =
                    friend.amount > 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down;
                Color iconColor =
                    friend.amount > 0 ? Colors.green : Colors.red;

                return ListTile(
                  title: Text(
                    "${friend.name}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0, // Adjust the font size as needed
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(iconData, color: iconColor),
                      Text(
                        "${friend.amount > 0 ? '+' : ''}\$${friend.amount}",
                        style: TextStyle(
                          color: friend.amount > 0 ? Colors.green : Colors.red,
                          fontSize: 16.0, // Adjust the font size as needed
                        ),
                      ),
                    ],
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
