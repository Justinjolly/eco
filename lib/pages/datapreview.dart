import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ExpenseGraph extends StatelessWidget {
  final String userId;

  ExpenseGraph({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Expense Graph'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('user_split_details')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final expenseData = snapshot.data!.docs.map((doc) => doc.data()).toList();
          final aggregatedData = aggregateExpenses(expenseData);
          return _buildChart(context, aggregatedData);
        },
      ),
    );
  }

  List<Map<DateTime, double>> aggregateExpenses(List<Map<String, dynamic>> expenseData) {
    // Create a Map to hold aggregated expenses by date
    Map<DateTime, double> aggregatedExpenses = {};

    // Iterate over each expense and sum up amounts for each date
    for (var expense in expenseData) {
      String? dateString = expense['timestamp'] as String?;
      if (dateString != null) {
        double? amount = expense['splitAmount'] as double?;
        DateTime date = _parseDate(dateString);
        // Strip off the time part
        date = DateTime(date.year, date.month, date.day);
        if (amount != null) {
          if (aggregatedExpenses.containsKey(date)) {
            aggregatedExpenses[date] = aggregatedExpenses[date]! + amount;
          } else {
            aggregatedExpenses[date] = amount;
          }
        }
      }
    }

    // Convert the Map to a List of Maps for easier charting
    return aggregatedExpenses.entries.map((entry) => {entry.key: entry.value}).toList();
  }

  DateTime _parseDate(String dateString) {
    return DateFormat("dd-MM-yyyy").parse(dateString);
  }

  Widget _buildChart(BuildContext context, List<Map<DateTime, double>> expenseData) {
    List<DateTime> dates = expenseData.map((data) => data.keys.first).toList();
    List<double> amounts = expenseData.map((data) => data.values.first).toList();

    return Container(
      padding: const EdgeInsets.only(top: 50.0, left: 60.0),
      
      width: 650, // Set width of the box
      height: 650, // Set height of the box
      child: Card(
        elevation: 10,
        color: const Color.fromARGB(255, 12, 12, 12),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Add elevation for a box effect
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: LineChart(
              LineChartData(
                minX: 0, // Starting X value
                maxX: dates.length > 0 ? dates.length.toDouble() : 0, // Ending X value
                minY: 0,
                maxY: getMaxYValue(amounts).toDouble(),
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTextStyles: (context, value) => const TextStyle(color: Color.fromARGB(255, 255, 254, 254), fontSize: 12),
                    getTitles: (value) {
                      // Manually specify the values you want to display on the y-axis
                      if (value == 0) {
                        return '0';
                      } else if (value == 100) {
                        return '100';
                      } else if (value == 200) {
                        return '200';
                      } else if (value == 300) {
                        return '300';
                      } else if (value == 400) {
                        return '400';
                      } else if (value == 500) {
                        return '500';
                      } else if (value == 600) {
                        return '600';
                      } else if (value == 700) {
                        return '700';
                      } else if (value == 800) {
                        return '800';
                      } else if (value == 900) {
                        return '900';
                      } else if (value == 1000) {
                        return '1000';
                      } else if (value == 1100) {
                        return '1100';
                      } else if (value == 1200) {
                        return '1200';
                      } else if (value == 1300) {
                        return '1300';
                      } else if (value == 1400) {
                        return '1400';
                      } else if (value == 1500) {
                        return '1500';
                      } else {
                        return '';
                      }
                    },
                  ),
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTextStyles: (context, value) => const TextStyle(color: Color.fromARGB(255, 255, 253, 253), fontSize: 12),
                    getTitles: (value) {
                      return _formatDate(dates[value.toInt()]); // Hide bottom titles
                    },
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                ),
                gridData: FlGridData(
                  show: false,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: getSpots(dates, amounts),
                    isCurved: true,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                    colors: [Colors.blue], // Specify colors here
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getMaxYValue(List<double> data) {
    double maxValue = 0;
    for (var amount in data) {
      if (amount > maxValue) {
        maxValue = amount;
      }
    }
    return maxValue;
  }

  List<FlSpot> getSpots(List<DateTime> dates, List<double> amounts) {
    List<FlSpot> spots = [];
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), amounts[i]));
    }
    return spots;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
