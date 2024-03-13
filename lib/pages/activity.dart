import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // Dummy transaction data for demonstration
  final List<Transaction> transactions = [
    Transaction(description: 'Shopping', amount: -50.0),
    Transaction(description: 'Salary', amount: 1000.0),
    Transaction(description: 'Dinner', amount: -30.0),
    Transaction(description: 'Gas', amount: -40.0),
    Transaction(description: 'Groceries', amount: -70.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity'),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(transaction.description),
            trailing: Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.amount >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

class Transaction {
  final String description;
  final double amount;

  Transaction({required this.description, required this.amount});
}

void main() {
  runApp(MaterialApp(
    home: ActivityPage(),
  ));
}
