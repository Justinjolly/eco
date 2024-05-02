import 'package:flutter/material.dart';

class EmailSettingsPage extends StatefulWidget {
  @override
  _EmailSettingsPageState createState() => _EmailSettingsPageState();
}

class _EmailSettingsPageState extends State<EmailSettingsPage> {
  bool isAddedToGroup = false;
  bool isAddedAsFriend = false;
  bool whenExpenseAdded = false;
  bool whenExpenseEditedDeleted = false;
  bool whenCommentOnExpense = false;
  bool whenExpenseDue = false;
  bool whenSomeonePaysMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            sectionTitle('Group and Friends'),
            checkboxListTile(
              'When someone adds me to a group',
              isAddedToGroup,
              (bool? value) {
                setState(() => isAddedToGroup = value!);
              },
            ),
            checkboxListTile(
              'When someone adds me as a friend',
              isAddedAsFriend,
              (bool? value) {
                setState(() => isAddedAsFriend = value!);
              },
            ),
            sectionTitle('Expenses'),
            checkboxListTile(
              'When an expense is added',
              whenExpenseAdded,
              (bool? value) {
                setState(() => whenExpenseAdded = value!);
              },
            ),
            checkboxListTile(
              'When an expense is edited/deleted',
              whenExpenseEditedDeleted,
              (bool? value) {
                setState(() => whenExpenseEditedDeleted = value!);
              },
            ),
            checkboxListTile(
              'When someone comments on an expense',
              whenCommentOnExpense,
              (bool? value) {
                setState(() => whenCommentOnExpense = value!);
              },
            ),
            checkboxListTile(
              'When an expense is due',
              whenExpenseDue,
              (bool? value) {
                setState(() => whenExpenseDue = value!);
              },
            ),
            checkboxListTile(
              'When someone pays me',
              whenSomeonePaysMe,
              (bool? value) {
                setState(() => whenSomeonePaysMe = value!);
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement what happens when the button is pressed
                  saveChanges();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,  // Text color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveChanges() {
    // Here you would typically call your method to save the preferences or update the state
    print('Settings Saved!');
  }

  Widget sectionTitle(String title) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget checkboxListTile(String title, bool value, void Function(bool?) onChanged) => ListTile(
    title: Text(
      title,
      style: TextStyle(fontSize: 18),
    ),
    trailing: Checkbox(
      value: value,
      onChanged: onChanged,
    ),
  );
}
