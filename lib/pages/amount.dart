import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripDetailsPage extends StatefulWidget {
  final List <QueryDocumentSnapshot> documentSnapshot;
  final String groupName;
  final String totalAmount;
  final int index;

  const TripDetailsPage(
      {super.key,
      required this.documentSnapshot,
      required this.groupName,
      required this.totalAmount, required this.index});

  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final users = [];
  late String totalAmount = '';
  late String groupName = '';
  late String Amount = '';
  late String userId = '';
  late String userName = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('amount')
        .doc('xFAtIwZSorKMVWV0ObsT')
        .get();
    final data = snapshot.data();
    userId = widget.documentSnapshot[widget.index]['userId'].toString();
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userData = userSnapshot.data();

    setState(() {
      userName = userName;
      userName = userData!['userName'].toString();
      users.clear();
final splitAmounts = widget.documentSnapshot[widget.index]['splitAmounts'];

for (var splitAmount in splitAmounts) {
  final member = splitAmount['member'];
  bool isRequester = false;
  
  if (member != null) {
    if (member is String) {
      if (member == userName) {
        isRequester = true;
      }
      users.add({'name': member, 'paid': false, 'requester': isRequester});
    } else if (member is int) {
      if (member.toString() == userName) {
        isRequester = true;
      }
      users.add({'name': member.toString(), 'paid': false, 'requester': isRequester});
    }
  }
}


      print(users);

      print(userId);

      print(userName);
      totalAmount = widget.documentSnapshot[widget.index]['totalAmount'].toString();
      groupName = widget.documentSnapshot[widget.index]['groupName'].toString();
    });
  }

  void _markAsPaid(int index) {
    setState(() {
      // Mark the user as paid
      users[index]['paid'] = true;

      // If the user is a requester, find and mark them as paid
      if (users[index].containsKey('requester') && users[index]['requester']) {
        for (var i = 0; i < users.length; i++) {
          if (users[i]['name'] == userName) {
            users[i]['paid'] = true;
            break; // Stop loop once the requester is found and marked as paid
          }
        }
      }
    });
  }

  int _countPaidUsers() {
    int count = 1;
    for (var user in users) {
      // Use null-aware operator to handle potential null value of 'paid'
      if (user['paid'] ?? false) {
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

    
    int paidUsers = _countPaidUsers();

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
              backgroundColor: Color.fromARGB(255, 1, 112, 1),
              child: Text(
                userName[0], // Access the first character of the member's name
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              // users.last['name']!.toString(),
              userName,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Total Amount',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4.0),
            Text('₹${totalAmount}', style: TextStyle(fontSize: 25)),
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
                        userName[
                            0], // Access the first character of the member's name
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(widget.documentSnapshot[widget.index]['splitAmounts'][index]['member'], style: TextStyle(fontSize: 18)),
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
                    trailing: Text('₹${widget.documentSnapshot[widget.index]['splitAmounts'][index]['amount'].toString()}', style: TextStyle(fontSize: 18)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action to be performed when the Pay button is pressed
        },
        label: Text('Pay'),
        icon: Icon(Icons.payment),
        backgroundColor: Colors.blue, // Customize button color as needed
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
);
}
}