import 'package:flutter/material.dart';

class FriendSettingsPage extends StatelessWidget {
  final Map<String, String> memberDetails;

  FriendSettingsPage({Key? key, required this.memberDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Text(memberDetails['name']![0], style: TextStyle(color: Colors.black)), // First letter of name
                ),
                SizedBox(width: 10),
                Text(memberDetails['name']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Text(memberDetails['email']!, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Remove from Friends List"),
                      content: Text("Are you sure you want to remove ${memberDetails['name']} from your friends list?"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            // Add your remove friend logic here
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // Use min size for the row
                children: [
                  Icon(Icons.person_remove, color: Colors.red), // Person icon with a cross
                  SizedBox(width: 8),
                  Text('Remove from Friends List', style: TextStyle(color: Colors.red, fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Block User"),
                      content: Text("Are you sure you want to block ${memberDetails['name']}?"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: Text("Block"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            // Add your block user logic here
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // Use min size for the row
                children: [
                  Icon(Icons.block), // Block user icon
                  SizedBox(width: 8),
                  Text('Block User', style: TextStyle( fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Report User"),
                      content: Text("Are you sure you want to report ${memberDetails['name']}?"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: Text("Report"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            // Add your block user logic here
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // Use min size for the row
                children: [
                  Icon(Icons.report), // Block user icon
                  SizedBox(width: 8),
                  Text('Report User', style: TextStyle( fontSize: 16)),
                ],
              ),
            ),
            // Additional content can follow here if needed
          ],
        ),
      ),
    );
  }
}
