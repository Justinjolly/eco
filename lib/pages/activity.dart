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

    QuerySnapshot<Map<String, dynamic>> groupSnapshot = await FirebaseFirestore
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

    List<String> groupNames = [];

    groupSnapshot.docs.forEach((doc) {
      String groupId = doc.id;
      String groupName = doc['groupName'];
      groupNames.add(groupName);
    });

    memberSnapshot.docs.forEach((doc) {
      String groupId = doc.id;
      String groupName = doc['groupName'];
      groupNames.add(groupName);
    });

    for (String groupName in groupNames) {
      QuerySnapshot<Map<String, dynamic>> amountSnapshot = await FirebaseFirestore
          .instance
          .collection('amount')
          .where('groupName', isEqualTo: groupName)
          .get();

      Map<String, List<String>> splitDetailsByDate = {};

      amountSnapshot.docs.forEach((doc) {
        String date = doc.data().containsKey('timestamp') ? _formatDate(doc['timestamp']) : 'Not specified';

        List<dynamic> splitAmounts = doc['splitAmounts'];
        int totalAmount = splitAmounts.fold<int>(0, (sum, split) => sum + (split['amount'] as int));

        String splitMessage = 'Split of $totalAmount created on $date in group $groupName';

        splitDetailsByDate.update(date, (value) => value + [splitMessage], ifAbsent: () => [splitMessage]);
      });

      splitDetailsByDate.forEach((date, splitMessages) {
        String groupCreatedMessage = 'Group "$groupName" created on $date';
        String? splitMessage = splitMessages.isNotEmpty
            ? '${groupCreatedMessage}\n\nSplit details:\n${splitMessages.join('\n')}'
            : null;

        groupActivities.add(GroupActivity(
          groupName: groupName,
          creationDate: date,
          splitMessage: splitMessage,
        ));
      });
    }

    return groupActivities;
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
    } else {
      // Assuming date is in the format dd-mm-yyyy
      List<String> parts = date.split('-');
      return '${parts[0]}-${parts[1]}-${parts[2]}';
    }
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
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'Group "${groupActivity.groupName}" created on ${groupActivity.creationDate}',
                      // ),
                      if (groupActivity.splitMessage != null)
                        Text(
                          groupActivity.splitMessage!,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                    ],
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
  final String? splitMessage;

  GroupActivity({
    required this.groupName,
    required this.creationDate,
    this.splitMessage,
  });
}
