import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripDetailsPage extends StatefulWidget {
  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  late List<Map<String, dynamic>> users = [];
  late String totalAmount = '';

  @override
  void initState() {
    super.initState();
    // Initialize users list and totalAmount from Firestore
    fetchTripDetails();
  }

  Future<void> fetchTripDetails() async {
    try {
      // Fetch trip details from Firestore
      final DocumentSnapshot tripSnapshot =
          await FirebaseFirestore.instance.collection('amount').doc('userId').get();

      // Update users list and totalAmount
      setState(() {
        users = List<Map<String, dynamic>>.from(tripSnapshot['userName'] ?? []);
        totalAmount = tripSnapshot['totalAmount'] ?? '';
      });
    } catch (error) {
      print('Error fetching trip details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty || totalAmount.isEmpty) {
      // Show loading indicator while data is being fetched
      return Scaffold(
        appBar: AppBar(
          title: Text('Trip'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
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
              // Avatar, Name, and Total Amount
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
                users.last['name']!,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Total Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                totalAmount,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),

              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Paid Users Count and Send Reminder Button
                    Text('${_countPaidUsers()} of ${users.length} paid'),
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
                      title: Text(user['name'], style: TextStyle(fontSize: 18)),
                      subtitle: Text(
                        user.containsKey('requester') && user['requester'] ? "Sent this request" : user['paid'] ? "Paid" : "Unpaid",
                        style: TextStyle(color: user.containsKey('requester') && user['requester'] ? Colors.grey : user['paid'] ? Colors.green : Colors.red),
                      ),
                      trailing: Text('\$${user['splitAmount']}'),
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
}
