import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'app_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'settingdetail/account_info.dart'; // AccountInfoPage import
import 'settingdetail/activity_log.dart'; // ActivityLogPage import
import 'settingdetail/security_settings.dart'; // SecuritySettingsPage import

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? statusMessage;

  @override
  void initState() {
    super.initState();
    _loadStatusMessage();
  }

  Future<void> _loadStatusMessage() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.user;

    if (user != null) {
      final document = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        statusMessage = document['status_message'];
      });
    }
  }

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
          child: SingleChildScrollView(
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
                _buildInfoRow(Icons.verified_user, 'Status: ${statusMessage ?? 'Loading...'}')
                    .animate()
                    .fadeIn(duration: 1500.ms)
                    .moveY(begin: 20, end: 0),
                const SizedBox(height: 20),
                Divider(thickness: 1.0, color: Colors.grey[300])
                    .animate()
                    .fadeIn(duration: 1700.ms)
                    .moveY(begin: 20, end: 0),
                const SizedBox(height: 20),
                _buildSettingsOption(
                  context,
                  icon: Icons.edit,
                  text: 'Edit Profile',
                  page: const AccountInfoPage(),
                  callback: _loadStatusMessage,
                ),
                _buildSettingsOption(
                  context,
                  icon: Icons.history,
                  text: 'Activity Log',
                  page: const ActivityLogPage(), // 활동 기록 페이지
                ),
                _buildSettingsOption(
                  context,
                  icon: Icons.security,
                  text: 'Security Settings',
                  page: const SecuritySettingsPage(), // 보안 설정 페이지
                ),
              ],
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

  Widget _buildSettingsOption(BuildContext context, {required IconData icon, required String text, required Widget page, VoidCallback? callback}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
        if (callback != null) {
          callback();
        }
      },
    );
  }
}
