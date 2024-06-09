import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:mad_team_minihead/app_state.dart';

class AccountInfoPage extends StatelessWidget {
  const AccountInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('계정 정보'),
        ),
        body: const Center(
          child: Text('로그인이 필요합니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('이메일: ${user.email}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('이름: ${user.displayName ?? '이름 없음'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 계정 정보 수정 기능 추가
              },
              child: const Text('수정'),
            ),
          ],
        ),
      ),
    );
  }
}
