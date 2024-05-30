import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState with ChangeNotifier {
  int _counter = 0;
  User? _user;
  int _selectedIndex = 0;

  int get counter => _counter;
  User? get user => _user;
  int get selectedIndex => _selectedIndex;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
