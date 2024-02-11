import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Splitter',
      theme: ThemeData.dark(), // Set the theme to dark
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
        title: Text('Create Group'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              child: Text('Create Group', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
