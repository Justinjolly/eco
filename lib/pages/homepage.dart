import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';
import 'groupcreate.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User _currentUser;
  List<GroupWidget> displayedGroups = [];
  FilterType currentFilter = FilterType.All;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchGroupsData();
  }

  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _fetchGroupsData() {
    _fetchGroupsFromFirestore().then((groupsFromFirestore) {
      setState(() {
        displayedGroups = groupsFromFirestore;

        // Fetch groups created from the create group page and merge them with existing groups
        ;
      });
    }).catchError((error) {
      print("Failed to fetch groups: $error");
    });
  }

  Future<List<GroupWidget>> _fetchGroupsFromFirestore() async {
    List<GroupWidget> groupsFromFirestore = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Convert 'groupType' to double
          double groupType = double.tryParse(data['groupType'].toString()) ?? 0;
          groupsFromFirestore.add(GroupWidget(
            name: data['groupName'] ?? '',
            totalDebt: groupType,
          ));
        }
      }
    } catch (error) {
      print("Failed to fetch groups from Firestore: $error");
    }

    return groupsFromFirestore;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              'Groups',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            PopupMenuButton<FilterType>(
              icon: Icon(Icons.filter_list, color: Colors.white),
              onSelected: (FilterType result) {
                setState(() {
                  currentFilter = result;
                  _applyFilter();
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<FilterType>>[
                PopupMenuItem<FilterType>(
                  value: FilterType.All,
                  child: Text('All Groups'),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserInfoSection(currentUser: _currentUser),
              OptionsSection(onGroupCreated: _fetchGroupsData),
              if (currentFilter == FilterType.All) ...{
                GroupsSection(),
              }
            ],
          ),
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
            'All Groups',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            itemCount: displayedGroups.length,
            itemBuilder: (context, index) {
              return displayedGroups[index];
            },
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    // Implement filtering logic if necessary
  }
}

class GroupWidget extends StatelessWidget {
  final String name;
  final double totalDebt;

  const GroupWidget({required this.name, required this.totalDebt});

  @override
  Widget build(BuildContext context) {
    Color amountColor = totalDebt > 0 ? Colors.red : Colors.green;

    return ListTile(
      title: Text(
        name,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Total Debt: \$${totalDebt.toString()}',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      trailing: Text(
        totalDebt.toString(),
        style: TextStyle(
          color: amountColor,
        ),
      ),
    );
  }
}

class UserInfoSection extends StatelessWidget {
  final User currentUser;

  const UserInfoSection({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 8.0),
          CircleAvatar(
            radius: 40.0,
            backgroundImage: AssetImage(
              'lib/assets/g.png', // Replace 'assets/predefined_image.jpg' with the path to your predefined image
            ),
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
                return Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white));
              }
              if (snapshot.hasData && snapshot.data != null) {
                final userData = snapshot.data!;
                final fullName = userData['fullName'];
                return Text(
                  fullName ?? 'Your Full Name',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }
              return Text('Your Full Name',
                  style: TextStyle(color: Colors.white));
            },
          ),
        ],
      ),
    );
  }
}

class OptionsSection extends StatelessWidget {
  final Function() onGroupCreated;

  const OptionsSection({required this.onGroupCreated});

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupCreate(),
                    ),
                  ).then((_) {
                    onGroupCreated();
                  });
                },
                child: Text('Create Group'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle Split option
                },
                child: Text('Split'),
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
}
