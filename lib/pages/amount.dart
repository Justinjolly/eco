import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyApp extends StatelessWidget {
  @override
 Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('amount').doc('your_document_id').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while fetching data
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final groupName = snapshot.data!['groupName'];
         final totalAmount = snapshot.data!['totalAmount'];
         final members = List<String>.from(snapshot.data!['splitAmount'].map((member) => member['member'])); // Fetch groupName from Firestore
        return MaterialApp(
           home: TripDetailsPage(groupName: groupName, totalAmount: totalAmount, members: members),
        );
      },
    );
  }
}


class TripDetailsPage extends StatefulWidget {
    final String groupName;
    final String totalAmount;
    final List<String> members;
   TripDetailsPage({required this.groupName, required this.totalAmount, required this.members});
  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
 List<Map<String, dynamic>> users = [];
  
  void initState() {
    super.initState();
    // Initialize the users list with members fetched from Firebase
    users = widget.members.map((member) => {'member': member, 'initial': member[0], 'paid': false}).toList();
    // Assuming there's no requester in the fetched members
  }
  void _markAsPaid(int index) {
    setState(() {
      users[index]['paid'] = true;
    });
  }

  int _countPaidUsers() {
    // Start count from 1 if the requester is not marked as paid, otherwise count normally
    int count = 1; // Assuming requester does not need to pay
    count += users.where((user) => user['paid'] == true).length;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    double splitAmount = 100.00 / users.length;
    int paidUsers = _countPaidUsers(); // Dynamically count paid users

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Navigate back
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Avatar, Name, and Total Amount Code remains unchanged
            // ...

            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                users.last['initial']!,
                style: TextStyle(fontSize: 40, color: Colors.black),
              ),
            ),
            SizedBox(height: 10),
            Text(
              users.last['member']!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Total Amount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.totalAmount,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),

            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${paidUsers} of ${users.length} paid'), // Updated dynamically
                  ElevatedButton(
                    onPressed: () {
                      // Logic to send reminder to unpaid users
                    },
                    child: Text('Send Reminder'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        user['initial'],
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    title: Text(user['member'], style: TextStyle(fontSize: 18)),
                    subtitle: Text(
                      user.containsKey('requester') && user['requester'] ? "Sent this request" : user['paid'] ? "Paid" : "Unpaid",
                      style: TextStyle(color: user.containsKey('requester') && user['requester'] ? Colors.grey : user['paid'] ? Colors.green : Colors.red),
                    ),
                    trailing: Text('\$${splitAmount.toStringAsFixed(2)}'),
                    onTap: () {
                      if (!user['paid'] && !(user.containsKey('requester') && user['requester'])) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Mark as Paid"),
                              content: Text("Do you want to mark ${user['name']} as paid?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                ),
                                TextButton(
                                  child: Text("Mark as Paid"),
                                  onPressed: () {
                                    _markAsPaid(index);
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
