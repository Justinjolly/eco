import 'package:flutter/material.dart';

class GroupCreate extends StatelessWidget {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: groupTypeController,
              decoration: InputDecoration(
                labelText: 'Group Type',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String groupName = groupNameController.text;
                String groupType = groupTypeController.text;

                if (groupName.isNotEmpty && groupType.isNotEmpty) {
                  print('Group Name: $groupName');
                  print('Group Type: $groupType');
                } else {
                  print('Please fill in all required fields');
                }
              },
              child:
                  Text('Create Group', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
