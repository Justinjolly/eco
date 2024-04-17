import 'package:flutter/material.dart';

class SelectedUserProvider extends ChangeNotifier {
  List<Map<String, String>> _selectedUsers = [];

  List<Map<String, String>> get selectedUsers => _selectedUsers;

  void updateSelectedUsers(List<Map<String, String>> users) {
    _selectedUsers = users;
    notifyListeners();
  }
}
