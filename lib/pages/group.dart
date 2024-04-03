import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for user authentication
import 'package:app/pages/groupsettings.dart';
import 'package:app/pages/homepage.dart';
import 'package:app/pages/split.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: HomePage(),
    );
  }
}

class GroupPage extends StatefulWidget {
  final String groupName;
  final User currentUser; // Add this line

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
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagesStream = _getMessagesStream();
    _fetchUsername();
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
    // If fetching the username fails, set it to a default value
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GroupSettingsPage(groupName: widget.groupName),
              ),
            );
          },
          child: Text(widget.groupName),
        ),
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
          ChatSection(onSendPressed: _sendMessage),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    try {
      await _firestore
          .collection('groups')
          .doc(widget.groupName)
          .collection('messages')
          .add({
        'message': message,
        'username': _username, // Use the current username
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Failed to send message: $e');
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

  const ChatSection({Key? key, required this.onSendPressed}) : super(key: key);

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
            icon: Icon(Icons.send), // Sent arrow icon
            onPressed: () {
              _sendMessageIfNotEmpty();
            },
          ),
          SizedBox(
              width: 8), // Add spacing between send button and split button
          IconButton(
            icon: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.white), // Add border here
                    borderRadius: BorderRadius.circular(
                        4), // Adjust border radius as needed
                  ),
                  padding: EdgeInsets.all(8), // Adjust padding as needed
                  child: Icon(Icons.attach_money), // "Split" icon
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
                MaterialPageRoute(builder: (context) => ExpenseEntryScreen()),
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
