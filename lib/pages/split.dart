import 'package:flutter/material.dart';

class SplitPage extends StatefulWidget {
  @override
  _SplitPageState createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  List<String> _members = ['John', 'Alice', 'Bob']; // Example list of members

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Splitter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Add Note',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Add Members to Split:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_members[index]),
                    value: false, // Implement functionality for member selection
                    onChanged: (value) {
                      // Implement functionality for member selection
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement functionality for submitting the expense
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
