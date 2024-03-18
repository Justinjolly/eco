import 'package:app/pages/split.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/pages/groupsettings.dart';
import 'package:app/pages/homepage.dart';

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
      home: HomePage(), // Change to HomePage
    );
  }
}

// GroupPage Widget
class GroupPage extends StatefulWidget {
  final String groupName;

  GroupPage({required this.groupName});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<String>> _messagesStream;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagesStream = _getMessagesStream();
  }

  Stream<List<String>> _getMessagesStream() {
    return _firestore
        .collection('groups')
        .doc(widget.groupName)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['message'] as String)
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Navigate to group settings page
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
      body: StreamBuilder<List<String>>(
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
                final reversedIndex = messages.length - 1 - index;
                return ListTile(
                  title: Text(
                    messages[index],
                    style: TextStyle(color: Colors.white),
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
                onSendPressed: (message) {
                  _sendMessage(message);
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

  void _sendMessage(String message) async {
    try {
      await _firestore
          .collection('groups')
          .doc(widget.groupName)
          .collection('messages')
          .add({
        'message': message,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Failed to send message: $e');
    }
  }
}

// ChatInputField Widget
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
