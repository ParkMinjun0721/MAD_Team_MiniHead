import 'package:flutter/material.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보안 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SwitchListTile(
              title: const Text('로그인 알림 활성화'),
              value: true,
              onChanged: (bool value) {
                // 로그인 알림 설정 변경 로직 추가
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phonelink_lock),
              title: const Text('2단계 인증 설정'),
              onTap: () {
                // 2단계 인증 설정 페이지로 이동
              },
            ),
          ],
        ),
      ),
    );
  }
}
