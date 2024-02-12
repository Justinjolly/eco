import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      home: ExpenseEntryScreen(),
    );
  }
}

class ExpenseEntryScreen extends StatefulWidget {
  @override
  _ExpenseEntryScreenState createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  bool _showGroupMembers = false;
  bool _showUnequallyMembers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Entry', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 150.0, bottom: 20.0, top: 20.0, right: 150.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAmountTextField(),
                SizedBox(height: 17.0),
                _buildNoteTextField(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: SectionButton(
                        title: 'Split Equally',
                        onPressed: () {
                          setState(() {
                            _showGroupMembers = !_showGroupMembers;
                            _showUnequallyMembers = false;
                          });
                        },
                        textColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: SectionButton(
                        title: 'Unequally',
                        onPressed: () {
                          setState(() {
                            _showUnequallyMembers = !_showUnequallyMembers;
                            _showGroupMembers = false;
                          });
                        },
                        textColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: SectionButton(
                        title: 'Section 3',
                        onPressed: () {
                          // Handle navigation or action for section 3
                        },
                      ),
                    ),
                  
                  ],
                ),
                Visibility(
                  visible: _showGroupMembers,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Group Members:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      _buildGroupMembersList(),
                    ],
                  ),
                ),
                Visibility(
                  visible: _showUnequallyMembers,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Unequally Distributed:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      _buildUnequallyMembersList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Amount',
       
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildNoteTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Note',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 212, 218, 240),
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
      maxLines: 1,
    );
  }

  Widget _buildGroupMembersList() {
    // Replace this with your list of group members
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member 1',
          style: TextStyle(color: Colors.white),
        ),
        Text(
          'Member 2',
          style: TextStyle(color: Colors.white),
        ),
        Text(
          'Member 3',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildUnequallyMembersList() {
    // Replace this with your list of unequally distributed members
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMemberWithAmount('Member 1'),
        _buildMemberWithAmount('Member 2'),
        _buildMemberWithAmount('Member 3'),
      ],
    );
  }

  Widget _buildMemberWithAmount(String memberName) {
    return Row(
      children: [
        Expanded(
          child: Text(
            memberName,
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.black),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 52, 52, 52),
              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}

class SectionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? textColor;

  const SectionButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}
