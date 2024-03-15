import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('groups').get();

    List<GroupActivity> groupActivities = [];

    snapshot.docs.forEach((doc) {
      // Assuming 'groupName' is a field in each document
      groupActivities.add(GroupActivity(
        groupName: doc['groupName'],
      ));
    });

    return groupActivities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  title: Text('Group "${groupActivity.groupName}" created'),
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

  GroupActivity({
    required this.groupName,
  });
}

void main() {
  runApp(MaterialApp(
    home: ActivityPage(),
  ));
}
