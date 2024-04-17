import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Split Amount Card Example'),
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SplitAmountCard(
                  totalAmount: 100.0,
                  numberOfPeople: 4,
                  peoplePaid: 2,
                  cardWidth: 250.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplitAmountCard extends StatelessWidget {
  final double totalAmount;
  final int numberOfPeople;
  final int peoplePaid;
  final double cardWidth;

  SplitAmountCard({
    required this.totalAmount,
    required this.numberOfPeople,
    required this.peoplePaid,
    this.cardWidth = 250.0,
  });

  @override
  Widget build(BuildContext context) {
    double splitAmount = totalAmount / numberOfPeople;
    double paidRatio = peoplePaid / numberOfPeople;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SizedBox(
        width: cardWidth,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Split Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                children: <Widget>[
                  Text(
                    '₹', // Rupee symbol
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    '${splitAmount.toStringAsFixed(2)} per person',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                '$peoplePaid/$numberOfPeople paid',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: paidRatio,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
