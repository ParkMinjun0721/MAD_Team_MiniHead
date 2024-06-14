import 'package:flutter/material.dart';

class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('활동 기록'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 20, // 활동 기록 항목 수 (예시)
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.history),
            title: Text('활동 기록 항목 ${index + 1}'),
            subtitle: Text('2024-05-21 14:30'), // 활동 시간 예시
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 활동 기록 상세보기 기능 구현
            },
          );
        },
      ),
    );
  }
}
