import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
      ),
      body: Center(
        child: const Text('여기에 도움말 항목들을 추가하세요.'),
      ),
    );
  }
}
