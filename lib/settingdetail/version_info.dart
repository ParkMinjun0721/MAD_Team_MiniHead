import 'package:flutter/material.dart';

class VersionInfoPage extends StatelessWidget {
  const VersionInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('버전 정보'),
      ),
      body: Center(
        child: Text(
          '앱 버전: 1.0.0',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
