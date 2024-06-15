import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  int _counter = 0;
  User? _user;
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  String _summaryText = '';
  List<Map<String, dynamic>> _files = []; // Add this line

  int get counter => _counter;
  User? get user => _user;
  int get selectedIndex => _selectedIndex;
  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  String get summaryText => _summaryText;
  List<Map<String, dynamic>> get files => _files; // Add this line

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

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  void setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    notifyListeners();
  }

  void setSummaryText(String text) {
    _summaryText = text;
    notifyListeners();
  }

  void setFiles(List<Map<String, dynamic>> files) { // Add this method
    _files = files;
    notifyListeners();
  }

  void updateFile(Map<String, dynamic> updatedFile) { // Add this method
    int index = _files.indexWhere((file) => file['id'] == updatedFile['id']);
    if (index != -1) {
      _files[index] = updatedFile;
      notifyListeners();
    }
  }

  void deleteFile(String fileId) { // Add this method
    _files.removeWhere((file) => file['id'] == fileId);
    notifyListeners();
  }
}
