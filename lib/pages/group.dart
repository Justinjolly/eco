import 'package:flutter/material.dart';
import 'package:app/pages/groupsettings.dart';
import 'package:app/pages/split.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to GroupPage and pass the group name
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupPage(groupName: "Your Group Name"),
              ),
            );
          },
          child: Text('Go to Group Page'),
        ),
      ),
    );
  }
}

class GroupPage extends StatefulWidget {
  final String groupName;

  GroupPage({required this.groupName});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Wrap the title in a GestureDetector
        title: GestureDetector(
          onTap: () {
            // Navigate to the next page and pass the group name
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
      // Set black background color
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                messages[index],
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  left: 8.0,
                  bottom: 8.0,
                  right: 8.0), // Adjust the padding as needed
              child: ChatInputField(
                onSendPressed: (message) {
                  setState(() {
                    messages.add(message);
                  });
                },
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(right: 8.0), // Adjust the padding as needed
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseEntryScreen()),
                ); 
              },
              child: Text('Split'),
            ),
          ),
        ],
      ),
    );
  }

  void _fetchMessages() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('groups')
          .doc(widget.groupName)
          .collection('messages')
          .get();

      setState(() {
        messages = querySnapshot.docs
            .map((doc) => doc.data()['message'] as String)
            .toList();
      });
    } catch (e) {
      print('Failed to fetch messages: $e');
    }
  }

  void _sendMessage(String message) async {
    try {
      await _firestore
          .collection('groups')
          .doc(widget.groupName)
          .collection('messages')
          .add({
        'message': message,
        'timestamp': Timestamp.now(), // Optionally include timestamp
      });
    } catch (e) {
      print('Failed to send message: $e');
    }
  }
}

class ChatInputField extends StatefulWidget {
  final Function(String) onSendPressed;

  const ChatInputField({Key? key, required this.onSendPressed})
      : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 2.0, top: 2.0, right: 0.0, left: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color.fromARGB(255, 255, 253, 253)),
        color: const Color.fromARGB(255, 48, 51, 53),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white), // Set text color to white
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey), // Set hint text color
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _sendMessage(value);
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              String message = _controller.text.trim();
              if (message.isNotEmpty) {
                _sendMessage(message);
              }
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    widget.onSendPressed(message);
    _controller.clear();
  }
}
