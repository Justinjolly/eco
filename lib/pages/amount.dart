import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TripDetailsPage(),
    );
  }
}

class TripDetailsPage extends StatefulWidget {
  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final users = [];
  late String totalAmount = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch data from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('amount')
        .doc('1rIUcqexnmXf5aNOWaKI')
        .get();
    final data = snapshot.data();
    print(data!['splitAmounts'].length);
    setState(() {
      users.clear(); // Clear existing users list
      for (var i = 0; i < data!['splitAmounts'].length; i++) {
        final splitAmount = data['splitAmounts'][i];
        final member = splitAmount['member'];
        print(member); // Assuming 'member' is a String
        if (member != null) {
          users.add({
            'name': member.toString()
          }); // Add 'member' as a map with 'name' key
        }
      }

      print(users);
      totalAmount = data['splitAmounts'][0]
          ['amount']; // Get 'amount' from the first splitAmount mapping
    });
  }

  void _markAsPaid(int index) {
    setState(() {
      users[index]['paid'] = true;
    });
  }

  int _countPaidUsers() {
    int count = 0;
    for (var user in users) {
      if (user['paid'] == true) {
        count++;
      }
    }
    return count;
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (users.isEmpty || totalAmount.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    double splitAmount = double.parse(totalAmount) / users.length;
    int paidUsers = _countPaidUsers();

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
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                'D', // Ensure 'initial' is treated as a String
                style: TextStyle(fontSize: 40, color: Colors.black),
              ),
            ),
            SizedBox(height: 10),
            Text(
              // users.last['name']!.toString(),
              'd',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Total Amount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              totalAmount,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${paidUsers} of ${users.length} paid'), // Updated dynamically
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
                        'd',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    title: Text(user['name'], style: TextStyle(fontSize: 18)),
                    subtitle: Text(
                      user.containsKey('requester') && user['requester']
                          ? "Sent this request"
                          : user['paid']
                              ? "Paid"
                              : "Unpaid",
                      style: TextStyle(
                          color:
                              user.containsKey('requester') && user['requester']
                                  ? Colors.grey
                                  : user['paid']
                                      ? Colors.green
                                      : Colors.red),
                    ),
                    trailing: Text('\$${splitAmount.toStringAsFixed(2)}'),
                    onTap: () {
                      if (!user['paid'] &&
                          !(user.containsKey('requester') &&
                              user['requester'])) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Mark as Paid"),
                              content: Text(
                                  "Do you want to mark ${user['name']} as paid?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                                TextButton(
                                  child: Text("Mark as Paid"),
                                  onPressed: () {
                                    _markAsPaid(index);
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
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
