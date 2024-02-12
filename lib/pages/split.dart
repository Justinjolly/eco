
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
      body: Center(
        child: Container(
          height: 100,
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[300], // Change the color as needed
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SectionButton(
                title: 'Section 1',
                onPressed: () {
                  // Handle navigation or action for section 1
                },
              ),
              SectionButton(
                title: 'Section 2',
                onPressed: () {
                  // Handle navigation or action for section 2
                },
              ),
              SectionButton(
                title: 'Section 3',
                onPressed: () {
                  // Handle navigation or action for section 3
                },
              ),
              SectionButton(
                title: 'Section 4',
                onPressed: () {
                  // Handle navigation or action for section 4
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const SectionButton({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
