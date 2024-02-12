import 'package:flutter/material.dart';

class BalancePage extends StatelessWidget {
  // Assuming a static balance for demonstration purposes
  // Replace this with your method of fetching the user's balance
  final double balance = 1234.56;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Balance'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Balance: \$${balance.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
