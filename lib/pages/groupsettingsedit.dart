import 'package:flutter/material.dart';

class CustomizeGroupPage extends StatefulWidget {
  @override
  _CustomizeGroupPageState createState() => _CustomizeGroupPageState();
}

class _CustomizeGroupPageState extends State<CustomizeGroupPage> {
  final TextEditingController _groupNameController = TextEditingController(text: "Trip");

  // Initialize the amount controller with the total amount value, allowing it to be edited.
  final TextEditingController _amountController = TextEditingController(text: "80.00"); // Assuming $80.00 as the total amount for demonstration.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize Group'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '🏝️',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group Name',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _groupNameController,
                        decoration: InputDecoration(
                          hintText: "Enter group name",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    hintText: "Enter total amount",
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Logic to handle when "Done" is pressed
                Navigator.pop(context);
              },
              child: Text('Done'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
