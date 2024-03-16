import 'package:app/pages/group.dart';
import 'package:app/pages/groupcreate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      });
    }).catchError((error) {
      print("Failed to fetch groups: $error");
    });
  }

  Future<List<GroupWidget>> _fetchGroupsFromFirestore() async {
  List<GroupWidget> groupsFromFirestore = [];

  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('groups').get();
    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        // Check if the logged-in user created the group or is a member of it
        if (data['creator'] == _currentUser.uid ||
            await _isUserMemberOfGroup(doc.reference as DocumentReference<Map<String, dynamic>>)) {
          // Convert 'groupType' to double
          double groupType =
              double.tryParse(data['groupType'].toString()) ?? 0;
          groupsFromFirestore.add(GroupWidget(
            name: data['groupName'] ?? '',
            totalDebt: groupType,
            onTap: () {
              // Navigate to the group page and pass the group name
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GroupPage(groupName: data['groupName']),
                ),
              );
            },
          ));
        }
      }
    }
  } catch (error) {
    print("Failed to fetch groups from Firestore: $error");
  }

  return groupsFromFirestore;
}


Future<bool> _isUserMemberOfGroup(DocumentReference groupReference) async {
  DocumentSnapshot groupSnapshot = await groupReference.get();
  
  Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;

  if (groupData != null) {
    List<dynamic>? members = groupData['members'];

    // Check if members is not null before accessing its contents
    if (members != null) {
      // Assuming _currentUser contains the user object
      String? currentUserID = _currentUser.uid;

      // Assuming you have a Firestore collection named 'users' containing user data
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserID).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        String? username = userData['userName'];

        if (username != null) {
          return members.contains(username);
        }
      }
    }
  }
  
  // If any required data is missing, the user is not considered a member
  return false;
}

  
  
  // If members is null or groupData is null, the user is not a member
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              'Home',
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
                GroupsSection(displayedGroups: displayedGroups),
              }
            ],
          ),
        ),
      ),
    );
  }

  void _applyFilter() {
    // Implement filtering logic if necessary
  }
}

class GroupsSection extends StatelessWidget {
  final List<GroupWidget> displayedGroups;

  const GroupsSection({required this.displayedGroups});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
                return Container(
                  margin: EdgeInsets.only(
                      bottom: 8.0), // Adjust margin as needed
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey, // Border color
                      width: .2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(
                        10.0), // Border radius
                  ),
                  child: displayedGroups[index],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Other Widget Classes (UserInfoSection, OptionsSection, GroupWidget) remain unchanged

  void _applyFilter() {
    // Implement filtering logic if necessary
  }


class GroupWidget extends StatefulWidget {
  final String name;
  final double totalDebt;
  final VoidCallback onTap;

  const GroupWidget({
    required this.name,
    required this.totalDebt,
    required this.onTap,
  });

  @override
  _GroupWidgetState createState() => _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  bool isMouseOver = false;

  @override
  Widget build(BuildContext context) {
    Color amountColor = widget.totalDebt > 0 ? Colors.red : Colors.green;
    Color backgroundColor = isMouseOver
        ? const Color.fromARGB(255, 81, 82, 82).withOpacity(0.5)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isMouseOver = true;
        });
      },
      onExit: (_) {
        setState(() {
          isMouseOver = false;
        });
      },
      child: Container(
        color: backgroundColor,
        child: ListTile(
          title: GestureDetector(
            onTap: widget.onTap,
            child: Text(
              widget.name,
              style: TextStyle(color: Colors.white),
            ),
          ),
          subtitle: Text(
            'Total Debt: \$${widget.totalDebt.toString()}',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Text(
            widget.totalDebt.toString(),
            style: TextStyle(
              color: amountColor,
            ),
          ),
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
      width: double.infinity,
      margin: EdgeInsets.all(20.0), // Adjust margins as needed
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 49, 51, 51), // Example background color
        borderRadius: BorderRadius.circular(10.0), // Example border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0.1,
            blurRadius: 7,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
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
              SizedBox(
                width: 120, // Fixed width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GroupCreate()),
                    ).then((_) {
                      onGroupCreated();
                    });
                  },
                  child: Text('Create Group'),
                ),
              ),
              SizedBox(
                width: 120, // Fixed width, same as the other button
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Split option
                  },
                  child: Text('Split'),
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
}
