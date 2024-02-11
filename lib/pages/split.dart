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

class ExpenseEntryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Entry', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.only(left:150.0,bottom: 20.0,top: 20.0,right: 150.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAmountTextField(),
            SizedBox(height: 17.0),
            _buildNoteTextField(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          borderSide: BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 52, 52, 52),
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), // Adjust padding
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildNoteTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Note',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          borderSide: BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 212, 218, 240),
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), // Adjust padding
      ),
      maxLines: 1,
    );
  }
}
