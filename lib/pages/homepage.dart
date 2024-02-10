import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _SplitwiseScreenState createState() => _SplitwiseScreenState();
}

class _SplitwiseScreenState extends State<HomePage> {
  late User _currentUser; // Add this variable to store the current user
  double totalAmountOwed = 0.0;
  final List<GroupWidget> allGroups = [
    GroupWidget(name: 'Group 1', totalDebt: 100),
    GroupWidget(name: 'Group 2', totalDebt: 50),
    GroupWidget(name: 'Group 3', totalDebt: 30),
    GroupWidget(name: 'Group 4', totalDebt: 20),
  ];

  List<GroupWidget> displayedGroups = [];
  List<GroupWidget> groupsIOwe = [
    GroupWidget(name: 'Group 1', totalDebt: 100),
    GroupWidget(name: 'Group 2', totalDebt: 50),
  ];

  List<GroupWidget> groupsOweMe = [
    GroupWidget(name: 'Group 3', totalDebt: 30),
    GroupWidget(name: 'Group 4', totalDebt: 50),
  ];

  List<FriendWidget> friendsIOwe = [
    FriendWidget(name: 'Friend 1', totalDebt: 50),
    FriendWidget(name: 'Friend 2', totalDebt: 30),
  ];

  List<FriendOweMeWidget> friendsOweMe = [
    FriendOweMeWidget(name: 'Friend 3', totalDebt: 40),
    FriendOweMeWidget(name: 'Friend 4', totalDebt: 25),
  ];

  FilterType currentFilter = FilterType.All;

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Call the method to fetch the current user on initialization
  }

  // Method to fetch the current user
  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'lib/assets/logo2.jpg',
                width: 50.0,
                height: 60.0,
              ),
            ),
            Text(
              'EcoExpense',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<FilterType>(
            icon: Icon(Icons.filter_list),
            onSelected: (FilterType result) {
              setState(() {
                currentFilter = result;
                _applyFilter();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterType>>[
              PopupMenuItem<FilterType>(
                value: FilterType.All,
                child: Text('All Groups'),
              ),
              PopupMenuItem<FilterType>(
                value: FilterType.GroupsIOwe,
                child: Text('Groups I Owe'),
              ),
              PopupMenuItem<FilterType>(
                value: FilterType.GroupsOweMe,
                child: Text('Groups That Owe Me'),
              ),
              PopupMenuItem<FilterType>(
                value: FilterType.FriendsIOwe,
                child: Text('Friends I Owe'),
              ),
              PopupMenuItem<FilterType>(
                value: FilterType.FriendsOweMe,
                child: Text('Friends That Owe Me'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserInfoSection(
                currentUser:
                    _currentUser), // Pass currentUser to UserInfoSection
            OptionsSection(),
            if (currentFilter == FilterType.GroupsIOwe ||
                currentFilter == FilterType.GroupsOweMe) ...{
              GroupsSection(),
            } else if (currentFilter == FilterType.FriendsIOwe) ...{
              FriendsIOweSection(),
            } else if (currentFilter == FilterType.FriendsOweMe) ...{
              FriendsOweMeSection(),
            } else ...{
              // Display all groups by default
              GroupsSection(),
              FriendsIOweSection(),
              FriendsOweMeSection(),
            }
          ],
        ),
      ),
    );
  }

  Widget GroupsSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getHeading(),
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          if (currentFilter == FilterType.All &&
              groupsIOwe.isNotEmpty &&
              groupsOweMe.isNotEmpty) ...{
            _buildGroupSection('Groups I Owe', groupsIOwe),
            _buildGroupSection('Groups That Owe Me', groupsOweMe),
          } else ...{
            ListView.builder(
              shrinkWrap: true,
              itemCount: displayedGroups.length,
              itemBuilder: (context, index) {
                return displayedGroups[index];
              },
            ),
          },
        ],
      ),
    );
  }

  Widget FriendsIOweSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends I Owe',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            itemCount: friendsIOwe.length,
            itemBuilder: (context, index) {
              return friendsIOwe[index];
            },
          ),
        ],
      ),
    );
  }

  Widget FriendsOweMeSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends That Owe Me',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            itemCount: friendsOweMe.length,
            itemBuilder: (context, index) {
              return friendsOweMe[index];
            },
          ),
        ],
      ),
    );
  }

  String _getHeading() {
    switch (currentFilter) {
      case FilterType.All:
        return 'All Groups';
      case FilterType.GroupsIOwe:
        return 'Groups I Owe';
      case FilterType.GroupsOweMe:
        return 'Groups That Owe Me';
      case FilterType.FriendsIOwe:
        return 'Friends I Owe';
      case FilterType.FriendsOweMe:
        return 'Friends That Owe Me';
    }
  }

  Widget _buildGroupSection(String title, List<GroupWidget> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.0),
        if (title != 'Groups That Owe Me' ||
            currentFilter != FilterType.All) ...{
          Text(
            title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        },
        SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return groups[index];
          },
        ),
      ],
    );
  }

  void _applyFilter() {
    switch (currentFilter) {
      case FilterType.All:
        setState(() {
          groupsIOwe = allGroups.where((group) => group.totalDebt > 0).toList();
          groupsOweMe =
              allGroups.where((group) => group.totalDebt < 0).toList();
          displayedGroups = List.from(allGroups);
        });
        break;
      case FilterType.GroupsIOwe:
        setState(() {
          displayedGroups = List.from(groupsIOwe);
        });
        break;
      case FilterType.GroupsOweMe:
        setState(() {
          displayedGroups = List.from(groupsOweMe);
        });
        break;
      case FilterType.FriendsIOwe:
        // Add logic to populate friendsIOwe list
        setState(() {
          // Replace this with actual data
          friendsIOwe = [
            FriendWidget(name: 'Friend 1', totalDebt: 50),
            FriendWidget(name: 'Friend 2', totalDebt: 30),
          ];
        });
        break;
      case FilterType.FriendsOweMe:
        // Add logic to populate friendsOweMe list
        setState(() {
          // Replace this with actual data
          friendsOweMe = [
            FriendOweMeWidget(name: 'Friend 3', totalDebt: 40),
            FriendOweMeWidget(name: 'Friend 4', totalDebt: 25),
          ];
        });
        break;
    }
  }
}

class GroupWidget extends StatelessWidget {
  final String name;
  final double totalDebt;

  const GroupWidget({required this.name, required this.totalDebt});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text('Total Debt: \$${totalDebt.toString()}'),
    );
  }
}

class FriendWidget extends StatelessWidget {
  final String name;
  final double totalDebt;

  const FriendWidget({required this.name, required this.totalDebt});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text('Total Debt: \$${totalDebt.toString()}'),
    );
  }
}

class FriendOweMeWidget extends StatelessWidget {
  final String name;
  final double totalDebt;

  const FriendOweMeWidget({required this.name, required this.totalDebt});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text('Total Debt: \$${totalDebt.toString()}'),
    );
  }
}

class UserInfoSection extends StatelessWidget {
  final User currentUser; // Add this variable

  const UserInfoSection({required this.currentUser}); // Update the constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          
          SizedBox(height: 8.0),
          Image.asset(
            'lib/assets/g.png', // Replace 'assets/predefined_image.jpg' with the path to your predefined image
            width: 80, // Adjust the width to your preference
            height: 80, // Adjust the height to your preference
          ),
          SizedBox(height: 8.0),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.hasData && snapshot.data != null) {
                final userData = snapshot.data!;
                final fullName = userData['fullName'];
                return Text(
                  fullName ?? 'Your Full Name',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
              return Text('Your Full Name');
            },
          ),
        ],
      ),
    );
  }
}

class OptionsSection extends StatelessWidget {
  final double totalAmountOwed = 150.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle Split option
                },
                child: Text('Split'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle Request option
                },
                child: Text('Request'),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Amount Owed: \$',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                totalAmountOwed.toString(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum FilterType {
  All,
  GroupsIOwe,
  GroupsOweMe,
  FriendsIOwe,
  FriendsOweMe,
}
