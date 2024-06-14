import 'package:flutter/material.dart';

Widget bottomNavigationBar(int currentIndex, Function(int) onTap) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onTap,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    items: const [
      BottomNavigationBarItem(
        label: 'Events',
        icon: Icon(Icons.home),
      ),

      BottomNavigationBarItem(
        label: 'Messages',
        icon: Icon(Icons.folder_copy),
      ),
      BottomNavigationBarItem(
        label: 'Settings',
        icon: Icon(Icons.person_2_rounded),
      ),
    ],
  );
}
