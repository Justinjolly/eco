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
        title: Text('Email Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
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
            sectionTitle('EXPENSES'),
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
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) => Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.5)),
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
