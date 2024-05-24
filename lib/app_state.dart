import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState with ChangeNotifier {
  int _counter = 0;
  User? _user;

  int get counter => _counter;
  User? get user => _user;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }
}
