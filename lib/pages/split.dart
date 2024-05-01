import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ExpenseEntryScreen extends StatefulWidget {
  final String groupName;
  ExpenseEntryScreen({
    required this.groupName,
  });
  @override
  _ExpenseEntryScreenState createState() => _ExpenseEntryScreenState();
}



List<TextEditingController> _unequallyControllers = [];

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  List<String> groupMembersList = [];
  bool _showGroupMembers = false;
  bool _showUnequallyMembers = false;
  bool _showPercentageMembers = false;
  final TextEditingController _amountController = TextEditingController();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


@override
  void initState() {

    _initializeLocalNotifications();
  }

 void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

Future<void> _showgroupNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Split',
      'New split has been created',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      "split",
      'New split has been created',
      platformChannelSpecifics,
    );
  }



  @override
  Widget build(BuildContext context) {
    _unequallyControllers = List<TextEditingController>.generate(
        groupMembersList.length > 1 ? groupMembersList.length - 1 : 0,
        (index) => TextEditingController());
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('groups');
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Expense Entry', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: collectionRef
            .where('groupName', isEqualTo: widget.groupName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('No data available');
          }
          groupMembersList.clear();
          for (var member in snapshot.data!.docs[0]['members']) {
            groupMembersList.add(member);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 150.0, bottom: 20.0, top: 20.0, right: 150.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAmountTextField(),
                    const SizedBox(height: 17.0),
                    _buildNoteTextField(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
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
                                // _showPercentageMembers = false;
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
                                // _showPercentageMembers = false;
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
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text(
                            'Equally Distributed:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          _buildGroupMembersList(),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _showUnequallyMembers,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text(
                            'Unequally Distributed:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          _buildUnequallyMembersList(),
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
                     _onSplitButtonPressed();  // Your existing function
                     _showgroupNotification();        // Another function to call
                       },
                      child: const Text(
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
      style: const TextStyle(color: Colors.white),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
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
          borderSide: const BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 19, 19, 21),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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
        if (_showUnequallyMembers) {
          // Split Unequally
          if (_unequallyControllers.isNotEmpty) {
            print('loop2');
            int totalSplitAmount = 0;
            for (int i = 0; i < _unequallyControllers.length - 1; i++) {
              int splitAmount = int.parse(
                  _unequallyControllers[i].text.isNotEmpty
                      ? _unequallyControllers[i].text
                      : '0');
              print('${_unequallyControllers[i]}');
              splitAmountsList
                  .add({'member': groupMembersList[i], 'amount': splitAmount});
              totalSplitAmount += splitAmount;
            }
            // Assign the remaining amount to the last member
            int remainingAmount = expenseAmount - totalSplitAmount;
            splitAmountsList.add(
                {'member': groupMembersList.last, 'amount': remainingAmount});
          }
        }
        if (_showPercentageMembers) {
          // Split Unequally
          if (_unequallyControllers.isNotEmpty) {
            print('loop2');
            int totalSplitAmount = 0;
            for (int i = 0; i < _unequallyControllers.length - 1; i++) {
              int splitAmount = int.parse(
                  _unequallyControllers[i].text.isNotEmpty
                      ? _unequallyControllers[i].text
                      : '0');
              print('${_unequallyControllers[i]}');
              splitAmountsList
                  .add({'member': groupMembersList[i], 'amount': splitAmount});
              totalSplitAmount += splitAmount;
            }
            // Assign the remaining amount to the last member
            int remainingAmount = 100 - totalSplitAmount;
            splitAmountsList.add(
                {'member': groupMembersList.last, 'amount': remainingAmount});
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
    _unequallyControllers = List<TextEditingController>.generate(
        groupMembersList.length,
        (index) => TextEditingController(
            text: (amount ~/ groupMembersList.length).toString()));

    int calculateSum() {
      return _unequallyControllers.fold<int>(
          0,
          (previousValue, controller) =>
              previousValue +
              int.parse(controller.text.isEmpty ? '0' : controller.text));
    }

    void adjustLastField() {
      final sum = calculateSum();
      final lastController = _unequallyControllers.last;
      final lastValue =
          int.parse(lastController.text.isEmpty ? '0' : lastController.text);
      final excess = sum - amount;
      final newValue = lastValue - excess;

      lastController.text = newValue.toString();
    }

    _unequallyControllers = List<TextEditingController>.generate(
        groupMembersList.length, (index) => TextEditingController());

    void onChangedCallback() {
      adjustLastField();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(groupMembersList.length, (index) {
        final memberName = groupMembersList[index];
        final controller = _unequallyControllers[index];

        return Row(
          children: [
            Expanded(
              child: Text(
                memberName,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _unequallyControllers[index],
                style: const TextStyle(color: Colors.white),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => onChangedCallback(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 52, 52, 52),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  
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
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: TextEditingController(
                    text: equallyDistributedAmount.toString()),
                style: const TextStyle(color: Colors.white),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {},
                enabled: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 52, 52, 52),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
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
