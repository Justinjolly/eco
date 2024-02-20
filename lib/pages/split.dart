import 'package:app/pages/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 36, 34, 34),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 36, 34, 34),
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
  bool _showPercentageMembers = false;

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Entry', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 150.0, bottom: 20.0, top: 20.0, right: 150.0),
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
                            _showPercentageMembers = false;
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
                            _showPercentageMembers = false;
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
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: _showGroupMembers,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
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
                      Divider(),
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
                  visible: _showPercentageMembers,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
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
                      _buildPercentageMembersList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder:(context)=>ChatScreen()
                      ),
                      );
                  },
                  child: Text(
                    'Split',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
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
      controller: _amountController,
      style: TextStyle(color: Colors.white),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        labelText: 'Amount',
        labelStyle: TextStyle(color: Colors.white),
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

 


Widget _buildUnequallyMembersList() {
  // Set the initial value of the unequally distributed fields based on the amount entered
  final amount = _amountController.text.isNotEmpty
      ? int.parse(_amountController.text)
      : 0;
  final controllers = <TextEditingController>[
    TextEditingController(text: (amount ~/ 3).toString()),
    TextEditingController(text: (amount ~/ 3).toString()),
    TextEditingController(text: (amount ~/ 3).toString()),
  ];

  // Function to calculate the sum of all inputs
  int calculateSum() {
    return controllers.fold<int>(
        0, (previousValue, controller) => previousValue + int.parse(controller.text.isEmpty ? '0' : controller.text));
  }

  // Adjusts the last member's input field to ensure the sum equals the amount
  void adjustLastField() {
    final sum = calculateSum();
    final lastController = controllers.last;
    final lastValue = int.parse(lastController.text.isEmpty ? '0' : lastController.text);
    final excess = sum - amount;
    final newValue = lastValue - excess;

    lastController.text = newValue.toString();
  }

  // Update other fields when a field is edited
  void onChangedCallback(int index) {
    adjustLastField();
    // You can add any additional handling here if needed
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(3, (index) {
      final memberName = 'Member ${index + 1}';
      final controller = controllers[index];

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
              controller: controller,
              style: TextStyle(color: Colors.white),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => onChangedCallback(index),
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
    }),
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
            controller: TextEditingController(
                text: (initialValue ~/ 3).toString()),
            style: TextStyle(color: Colors.white),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              // Calculation logic for each member input field
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.black),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 52, 52, 52),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildLastMemberWithAmount(String memberName, int initialValue) {
    TextEditingController lastMemberController = TextEditingController(
      text: (initialValue ~/ 3).toString(),
    );

    lastMemberController.addListener(() {
      int sum = 0;
      sum += int.parse(lastMemberController.text.isEmpty ? '0' : lastMemberController.text);
      sum += int.parse(_amountController.text) -
          int.parse(lastMemberController.text.isEmpty ? '0' : lastMemberController.text) -
          int.parse((_amountController.text.isEmpty ? '0' : _amountController.text) +
              ((2 * initialValue -
                      int.parse(lastMemberController.text.isEmpty ? '0' : lastMemberController.text)) ~/
                  2).toString());

      if (sum != initialValue) {
        int excess = sum - initialValue;
        int newValue = int.parse(lastMemberController.text) - excess;
        lastMemberController.text = newValue.toString();
      }
    });

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
            controller: lastMemberController,
            style: TextStyle(color: Colors.white),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.black),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 52, 52, 52),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
Widget _buildPercentageMembersList() {
  List<String> groupMembers = ['Member 1', 'Member 2', 'Member 3'];

  final controllers = List<TextEditingController>.generate(
      groupMembers.length, (index) => TextEditingController());

  void onChangedCallback() {
    int totalPercentage = controllers.fold<int>(
        0,
        (previousValue, controller) =>
            previousValue + int.parse(controller.text.isEmpty ? '0' : controller.text));
    int excess = totalPercentage - 100;
    if (excess != 0) {
      int lastValue = int.parse(
          controllers.last.text.isEmpty ? '0' : controllers.last.text);
      lastValue -= excess;
      controllers.last.text = lastValue.toString();
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(groupMembers.length, (index) {
      final memberName = groupMembers[index];
      final controller = controllers[index];

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
              controller: controller,
              style: TextStyle(color: Colors.white),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => onChangedCallback(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 52, 52, 52),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 10.0),
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
    }),
  );
}

Widget _buildGroupMembersList() {
  List<String> groupMembers = ['Member 1', 'Member 2', 'Member 3'];

  final amount = _amountController.text.isNotEmpty
      ? int.parse(_amountController.text)
      : 0;
  final equallyDistributedAmount =
      amount ~/ groupMembers.length; // Calculate equally distributed amount

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
              controller: TextEditingController(
                  text: equallyDistributedAmount.toString()),
              style: TextStyle(color: Colors.white),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}
