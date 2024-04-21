import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpenseEntryScreen extends StatefulWidget {
  final String groupName;
  ExpenseEntryScreen({
    required this.groupName,
  });
  @override
  _ExpenseEntryScreenState createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  List<String> groupMembersList = [];
  bool _showGroupMembers = false;
  bool _showUnequallyMembers = false;
  bool _showPercentageMembers = false;
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('groups');
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Entry', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: collectionRef
            .where('groupName', isEqualTo: widget.groupName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No data available');
          }
          groupMembersList.clear();
          for (var member in snapshot.data!.docs[0]['members']) {
            groupMembersList.add(member);
          }

          return Column(
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
                                _showPercentageMembers =
                                    !_showPercentageMembers;
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
                      onPressed: _onSplitButtonPressed,
                      child: Text(
                        'Split',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAmountTextField() {
    return TextField(
      controller: _amountController,
      style: TextStyle(color: Colors.white),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
        fillColor: Color.fromARGB(255, 19, 19, 21),
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
      maxLines: 1,
    );
  }

 void _onSplitButtonPressed() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final String userId = currentUser.uid;
    String userName = currentUser.displayName ?? 'Unknown';
    if (userName == 'Unknown') {
      // If display name is not available, use email as the username
      userName = currentUser.email ?? 'Unknown';
    }
    int expenseAmount = _amountController.text.isNotEmpty
        ? int.parse(_amountController.text)
        : 0;
    try {
      final CollectionReference amountRef =
          FirebaseFirestore.instance.collection('amount');

      // Create a list to hold member names and their split amounts as objects
      List<Map<String, dynamic>> splitAmountsList = [];
        if (_showGroupMembers) {
      // Split Equally
      int splitAmount = expenseAmount ~/ groupMembersList.length;
      for (var member in groupMembersList) {
        splitAmountsList.add({'member': member, 'amount': splitAmount});
      }
      }
      else if(_showUnequallyMembers){
      int splitAmount = 
          expenseAmount ~/ groupMembersList.length;
      for (var member in groupMembersList) {
        splitAmountsList.add({'member': member, 'amount': splitAmount});
      }  
      }
      // Store member names, split amounts, total amount, and user details in a single document
      await amountRef.add({
        'userId': userId,
        'userName': userName,
        'groupName': widget.groupName,
        'totalAmount': expenseAmount,
        'splitAmounts': splitAmountsList,
        'timestamp': Timestamp.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error storing data: $e');
    }
  }
}





  Widget _buildUnequallyMembersList() {
    final amount = _amountController.text.isNotEmpty
        ? int.parse(_amountController.text)
        : 0;
    final controllers = List<TextEditingController>.generate(
        groupMembersList.length,
        (index) => TextEditingController(
            text: (amount ~/ groupMembersList.length).toString()));

    int calculateSum() {
      return controllers.fold<int>(
          0,
          (previousValue, controller) =>
              previousValue + int.parse(controller.text.isEmpty ? '0' : controller.text));
    }

    void adjustLastField() {
      final sum = calculateSum();
      final lastController = controllers.last;
      final lastValue =
          int.parse(lastController.text.isEmpty ? '0' : lastController.text);
      final excess = sum - amount;
      final newValue = lastValue - excess;

      lastController.text = newValue.toString();
    }

    void onChangedCallback(int index) {
      adjustLastField();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(groupMembersList.length, (index) {
        final memberName = groupMembersList[index];
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => onChangedCallback(index),
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
      }),
    );
  }

  Widget _buildPercentageMembersList() {
    final controllers = List<TextEditingController>.generate(
        groupMembersList.length, (index) => TextEditingController());

    void onChangedCallback() {
      int totalPercentage = controllers.fold<int>(
          0,
          (previousValue, controller) =>
              previousValue +
              int.parse(controller.text.isEmpty ? '0' : controller.text));
      int excess = totalPercentage - 100;
      if (excess != 0) {
        int lastValue =
            int.parse(controllers.last.text.isEmpty ? '0' : controllers.last.text);
        lastValue -= excess;
        controllers.last.text = lastValue.toString();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(groupMembersList.length, (index) {
        final memberName = groupMembersList[index];
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
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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
    final amount = _amountController.text.isNotEmpty
        ? int.parse(_amountController.text)
        : 0;
    final equallyDistributedAmount = amount ~/ groupMembersList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupMembersList.map((memberName) {
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {},
                enabled: false,
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
