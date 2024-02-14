import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter

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
  bool _showPercentageMembers = false; // New variable to control visibility of percentage members

  // Controller for the amount field
  final TextEditingController _amountController = TextEditingController();

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
                            _showPercentageMembers = false; // Reset visibility for other sections
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
                            _showPercentageMembers = false; // Reset visibility for other sections
                          });
                        },
                        textColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: SectionButton(
                        title: 'Percentage',
                        onPressed: () {
                          setState(() {
                            _showPercentageMembers = !_showPercentageMembers;
                            _showGroupMembers = false;
                            _showUnequallyMembers = false;
                          });
                        },
                        textColor: Colors.white, // Setting text color to white
                      ),
                    ),
                 
                  ],
                ),
                Visibility(
                  visible: _showGroupMembers,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(), // Divider above the section heading
                      SizedBox(height: 10),
                      Text(
                        'Equally Distributed:',
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
                      Divider(), // Divider above the section heading
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
                Visibility(
                  visible: _showPercentageMembers, // Display if _showPercentageMembers is true
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(), // Divider above the section heading
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
                      _buildPercentageMembersList(), // Display the list of group members with percentage inputs
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded( // Added Expanded widget to take remaining space
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Implement the logic for the "Pay" action here
                    print('Pay button clicked');
                  },
                  child: Text(
                    'Split',
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)), // Set text color to white
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountTextField() {
    return TextField(
      controller: _amountController, // Assign controller to the amount field
      style: TextStyle(color: Colors.white), // Set text color to white
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
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

  Widget _buildPercentageMembersList() {
    List<String> groupMembers = ['Member 1', 'Member 2', 'Member 3']; // Replace with your list of group members
    List<TextEditingController> controllers = List.generate(groupMembers.length, (index) => TextEditingController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupMembers.asMap().entries.map((entry) {
        final int index = entry.key;
        final String memberName = entry.value;

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
                controller: controllers[index],
                style: TextStyle(color: Colors.white),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                onChanged: (value) {
                  // Calculate the sum of percentages
                  int sum = 0;
                  controllers.forEach((controller) {
                    if (controller.text.isNotEmpty) {
                      sum += int.parse(controller.text);
                    }
                  });

                  // Check if sum exceeds 100, if so, adjust the last edited field
                  if (sum > 100) {
                    int excess = sum - 100;
                    int newValue = int.parse(value) - excess;
                    controllers[index].text = newValue.toString();
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 52, 52, 52),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  suffixIcon: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      '%',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildUnequallyMembersList() {
    // Set the initial value of the unequally distributed fields based on the amount entered
    final amount = _amountController.text.isNotEmpty ? int.parse(_amountController.text) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMemberWithAmount('Member 1', amount),
        _buildMemberWithAmount('Member 2', amount),
        _buildMemberWithAmount('Member 3', amount),
      ],
    );
  }

  Widget _buildMemberWithAmount(String memberName, int initialValue) {
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
            controller: TextEditingController(text: (initialValue ~/ 3).toString()), // Set initial value
            style: TextStyle(color: Colors.white), // Set text color to white
            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
            onChanged: (value) {
              // Calculate the sum of all inputs in the unequally distributed fields
              int sum = 0;
              sum += int.parse(value.isEmpty ? '0' : value); // Add the value of the changed field
              sum += int.parse(((3 * initialValue - int.parse(value.isEmpty ? '0' : value)) ~/ 2) as String); // Add the sum of other fields

              // Check if sum exceeds the amount, if so, adjust the last edited field
              if (sum > initialValue) {
                int excess = sum - initialValue;
                int newValue = int.parse(value) - excess;
                setState(() {
                  // Set the new value for the edited field
                  _amountController.text = (int.parse(_amountController.text) - excess).toString();
                });
                // Set the value of the edited field
                value = newValue.toString();
              }
            },
            decoration: InputDecoration(
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

  Widget _buildGroupMembersList() {
    List<String> groupMembers = ['Member 1', 'Member 2', 'Member 3']; // Replace with your list of group members
    final amount = _amountController.text.isNotEmpty ? int.parse(_amountController.text) : 0;
    final equallyDistributedAmount = amount ~/ groupMembers.length; // Calculate equally distributed amount

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupMembers.map((memberName) {
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
                controller: TextEditingController(text: equallyDistributedAmount.toString()), // Set initial value
                style: TextStyle(color: Colors.white), // Set text color to white
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                onChanged: (value) {
                  // You can add any additional handling here if needed
                },
                enabled: false, // Make the text field not editable
                decoration: InputDecoration(
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
      }).toList(),
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
