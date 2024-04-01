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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<Map<String, dynamic>>> _messagesStream;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagesStream = _getMessagesStream();
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ChatInputField(
                groupName: widget.groupName,
                onSendPressed: (message) async {
                  if (widget.currentUser != null) {
                    final displayName = widget.currentUser.displayName;
                    final username =
                        displayName != null ? displayName : "Unknown User";
                    final timestamp = Timestamp.now();
                    await _sendMessage(message, username, timestamp);
                  }
                },
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseEntryScreen()),
                );
              },
              child: Text('Split'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(
      String message, String username, Timestamp timestamp) async {
    try {
      await _firestore
          .collection('groups')
          .doc(widget.groupName)
          .collection('messages')
          .add({
        'message': message,
        'username': username,
        'timestamp': timestamp,
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

class ChatInputField extends StatefulWidget {
  final String groupName;
  final Function(String) onSendPressed;

  const ChatInputField({
    Key? key,
    required this.groupName,
    required this.onSendPressed,
  }) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey[900],
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
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => _sendMessage(_controller.text.trim()),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      widget.onSendPressed(message);
      _controller.clear();
    }
  }
}
