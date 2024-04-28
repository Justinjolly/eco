import 'package:app/pages/amount.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'split.dart';
import 'groupsettings.dart';
import 'package:app/pages/account.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Split Amount Card Example'),
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: GroupPage(
                    groupName: 'example_group',
                    currentUser: FirebaseAuth.instance.currentUser!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupPage extends StatefulWidget {
  final String groupName;
  final User currentUser;

  GroupPage({
    required this.groupName,
    required this.currentUser,
  });

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late String _username;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<Map<String, dynamic>>> _messagesStream;
  late Stream<Map<String, dynamic>>
      _splitStream; // Updated stream for split details
  final TextEditingController _controller = TextEditingController();
  bool _showNotification = true;

  @override
  void initState() {
    super.initState();
    _messagesStream = _getMessagesStream();
    _splitStream =
        _getCombinedSplitStream(); // Initialize combined split stream
    _fetchUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupSettingsPage(
                    groupName: widget.groupName,
                    groupMembers: [],
                    currentUsername: _username),
              ),
            );
          },
          child: Text(widget.groupName),
        ),
        actions: [
          if (_showNotification)
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupSettingsPage(
                        groupName: widget.groupName,
                        groupMembers: [],
                        currentUsername: _username),
                  ),
                );
              } else if (result == 'clear') {
                _confirmClearChatHistory();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Group Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Text('Clear Chat History'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final messages = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Text(
                          '${message["username"]}: ${message["message"]}',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${_formatTimestamp(message["timestamp"])}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('amount')
                .where('groupName', isEqualTo: widget.groupName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final documents =
                    snapshot.data!.docs; // Accessing documents directly
                print(documents);

                if (documents.isEmpty) {
                  return SizedBox
                      .shrink(); // Hide split card if no split details
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot = documents[index];

                        return SplitAmountCard(
                totalAmount: documentSnapshot['totalAmount'],
                groupName: documentSnapshot['groupName'],
              );
                      },
                    ),
                  );
                }
              }
            },
          ),
          ChatSection(onSendPressed: _sendMessage, groupName: widget.groupName),
        ],
      ),
    );
  }

  Future<void> _fetchUsername() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.currentUser.uid)
              .get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData = userSnapshot.data();
        if (userData != null && userData.containsKey('userName')) {
          setState(() {
            _username = userData['userName'];
          });
          return;
        }
      }
    } catch (error) {
      print('Error fetching username: $error');
    }
    setState(() {
      _username = 'Unknown User';
    });
  }

  Stream<List<Map<String, dynamic>>> _getMessagesStream() {
    return _firestore
        .collection('groups')
        .doc(widget.groupName)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  Stream<Map<String, dynamic>> _getCombinedSplitStream() {
    return _getSplitStream().map((splitDetailsList) {
      if (splitDetailsList.isNotEmpty) {
        final splitDetails = splitDetailsList.first;
        final totalAmount = splitDetails['totalAmount'] ?? 0.0;
        final splitAmounts = splitDetails['splitAmounts'] ?? [];
        print('Total amount: $totalAmount');
        print('Split amounts: $splitAmounts');
        return {
          'totalAmount': totalAmount,
          'splitAmounts': splitAmounts,
        };
      } else {
        return {
          'totalAmount': 0.0,
          'splitAmounts': [],
        };
      }
    });
  }

  Stream<Iterable<Map<String, dynamic>>> _getSplitStream() {
    return _firestore.collection('amount').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) =>
              doc['groupName'] ==
              widget.groupName) // Filter documents based on 'groupName' field
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure that 'totalAmount' and 'splitAmounts' are properly cast to expected types
        final totalAmount = (data['totalAmount'] ?? 0.0) as double;
        final splitAmounts = (data['splitAmounts'] ?? []) as List<dynamic>;
        return {
          'totalAmount': totalAmount,
          'splitAmounts': splitAmounts,
        };
      }).toList();
    });
  }

  Future<void> _sendMessage(String message) async {
    try {
      await _firestore
          .collection('groups')
          .doc(widget.groupName)
          .collection('messages')
          .add({
        'message': message,
        'username': _username,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  void _confirmClearChatHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Clear Chat History"),
          content: Text("Are you sure you want to clear all chat history?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearChatHistory();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _clearChatHistory() async {
    try {
      await _firestore
          .collection('groups')
          .doc(widget.groupName)
          .collection('messages')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
    } catch (e) {
      print('Failed to clear chat history: $e');
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final dateTime = timestamp.toDate();
    final dateFormat = DateFormat('dd/MM/yyyy').format(dateTime);
    final timeFormat = '${dateTime.hour}:${dateTime.minute}';

    return '$dateFormat $timeFormat';
  }
}

class ChatSection extends StatefulWidget {
  final Function(String) onSendPressed;
  final String groupName;

  const ChatSection(
      {Key? key, required this.onSendPressed, required this.groupName})
      : super(key: key);

  @override
  _ChatSectionState createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onSubmitted: (_) {
                _sendMessageIfNotEmpty();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessageIfNotEmpty();
            },
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.attach_money),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black,
                    child: Text(
                      'Split',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ExpenseEntryScreen(groupName: widget.groupName)),
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendMessageIfNotEmpty() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSendPressed(message);
      _controller.clear();
    }
  }
}

class SplitAmountCard extends StatelessWidget {
  final double totalAmount;
  final String groupName;

  SplitAmountCard({
    required this.totalAmount,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TripDetailsPage(groupName: groupName, totalAmount: totalAmount.toStringAsFixed(2),), // Replace AnotherPage with the desired page
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Split Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
