import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'app_state.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('No user is logged in'),
        ),
      );
    }

    final appWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
                  const SnackBar(content: Text('Successfully logged out')),
                );
                appState.setUser(null); // 앱 상태에서 사용자 정보 제거
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: appWidth * 0.35,
                    height: appWidth * 0.35,
                    child: user.photoURL != null
                        ? ClipOval(
                      child: Image.network(
                        user.photoURL!,
                        width: appWidth * 0.35,
                        height: appWidth * 0.35,
                        fit: BoxFit.cover,
                      ),
                    ).animate().fadeIn(duration: 500.ms).scale()
                        : Icon(Icons.account_circle, size: appWidth * 0.35, color: Colors.grey)
                        .animate().fadeIn(duration: 500.ms).scale(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.displayName ?? 'Anonymous Name',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ).animate().fadeIn(duration: 700.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 10),
                  Text(
                    user.email ?? 'Anonymous Email',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ).animate().fadeIn(duration: 900.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 20),
                  Divider(thickness: 1.0, color: Colors.grey[300])
                      .animate()
                      .fadeIn(duration: 1100.ms)
                      .moveY(begin: 20, end: 0),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.person, 'UID: ${user.uid}')
                      .animate()
                      .fadeIn(duration: 1300.ms)
                      .moveY(begin: 20, end: 0),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.verified_user, 'Status: I promise to take the test honestly before GOD')
                      .animate()
                      .fadeIn(duration: 1500.ms)
                      .moveY(begin: 20, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
