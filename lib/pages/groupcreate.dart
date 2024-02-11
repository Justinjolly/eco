import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Splitter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplitForm(),
    );
  }
}

class SplitForm extends StatefulWidget {
  @override
  _SplitFormState createState() => _SplitFormState();
}

class _SplitFormState extends State<SplitForm> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Group'),
        leading: Image.asset(
          'lib/assets/logo2.jpg',  // Replace with the actual path to your logo image
          width: 50,  // Adjust the width as needed
          height: 60, // Adjust the height as needed
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: groupTypeController,
              decoration: InputDecoration(labelText: 'Group Type'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Handle button press here
                String groupName = groupNameController.text;
                String groupType = groupTypeController.text;

                // Validate and create group if needed
                if (groupName.isNotEmpty && groupType.isNotEmpty) {
                  // Create the group or perform any other necessary actions
                  print('Group Name: $groupName');
                  print('Group Type: $groupType');
                  // You can add logic here to create the group
                } else {
                  // Show an error message or handle the case when required fields are not filled
                  print('Please fill in all required fields');
                }
              },
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
