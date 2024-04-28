import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late Future<List<GroupActivity>> _groupActivities;

  @override
  void initState() {
    super.initState();
    _groupActivities = _getGroupActivities();
  }

 Future<List<GroupActivity>> _getGroupActivities() async {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
      .instance
      .collection('groups')
      .where('creator', isEqualTo: userId)
      .get();

  QuerySnapshot<Map<String, dynamic>> memberSnapshot = await FirebaseFirestore
      .instance
      .collection('groups')
      .where('members', arrayContains: userId)
      .get();

  Set<String> addedGroups = {}; // Set to keep track of added group IDs

  List<GroupActivity> groupActivities = [];

  snapshot.docs.forEach((doc) {
    String groupId = doc.id;
    if (!addedGroups.contains(groupId)) {
      String groupName = doc['groupName'];
      String creationDate = doc.data().containsKey('creationDate') ? _formatDate(doc['creationDate']) : 'Not specified';
      groupActivities.add(GroupActivity(
        groupName: groupName,
        creationDate: creationDate,
      ));
      addedGroups.add(groupId); // Add group ID to set
    }
  });

  memberSnapshot.docs.forEach((doc) {
    String groupId = doc.id;
    if (!addedGroups.contains(groupId)) {
      String groupName = doc['groupName'];
      String creationDate = doc.data().containsKey('creationDate') ? _formatDate(doc['creationDate']) : 'Not specified';
      groupActivities.add(GroupActivity(
        groupName: groupName,
        creationDate: creationDate,
      ));
      addedGroups.add(groupId); // Add group ID to set
    }
  });

  return groupActivities;
}




  String _formatDate(String date) {
    // Assuming date is in the format dd-mm-yyyy
    List<String> parts = date.split('-');
    return '${parts[0]}-${parts[1]}-${parts[2]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Activity'),
      ),
      body: FutureBuilder<List<GroupActivity>>(
        future: _groupActivities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                final groupActivity = snapshot.data![index];
                return ListTile(
                  title: Text(
                    'Group "${groupActivity.groupName}" created on ${groupActivity.creationDate}',
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class GroupActivity {
  final String groupName;
  final String creationDate;

  GroupActivity({
    required this.groupName,
    required this.creationDate,
  });
}

void main() {
  runApp(MaterialApp(
    home: ActivityPage(),
  ));
}
