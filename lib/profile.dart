import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'app_state.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: Text('No user is logged in'),
        ),
      );
    }

    final appWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              semanticLabel: 'logout',
            ),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                print('Successfully logged out');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully logged out')),
                );
                appState.setUser(null); // 앱 상태에서 사용자 정보 제거
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                      (Route<dynamic> route) => false,
                );
              } catch (e) {
                print('Logout failed: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: appWidth * 0.35,
              height: appWidth * 0.35,
              child: user.photoURL != null
                  ? Image.network(user.photoURL!)
                  : Icon(Icons.account_circle, size: appWidth * 0.35),
            ),
            Text(
              'UID: ${user.uid}',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'Email: ${user.email ?? 'Anonymous'}',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Name: ${user.displayName ?? 'anonymous name'}',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'I promise to take the test honestly before GOD',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
