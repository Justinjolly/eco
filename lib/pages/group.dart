import 'package:flutter/material.dart';
import 'package:app/pages/groupsettings.dart';
import 'package:app/pages/split.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Define group name variable
  String groupName = "Your Group Name";

  List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  // Wrap the title in a GestureDetector
  title: GestureDetector(
    onTap: () {
      // Navigate to the page you want
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GroupSettingsPage()
        ),
      );
    },
    child: Text(groupName),
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
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
            );
          },
        ),
      ),
     bottomNavigationBar: Row(
  children: [
    Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 8.0,bottom: 8.0,right: 8.0), // Adjust the padding as needed
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
      padding: EdgeInsets.only(right: 8.0), // Adjust the padding as needed
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder:(context)=>ExpenseEntryScreen()
            ),
            );// Handle split button press
        },
        child: Text('Split'),
      ),
    ),
  ],
),


    );
  }
}

class ChatInputField extends StatefulWidget {
  final Function(String) onSendPressed;

  const ChatInputField({Key? key, required this.onSendPressed}) : super(key: key);

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
