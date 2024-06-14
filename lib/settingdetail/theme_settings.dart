import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mad_team_minihead/app_state.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('테마 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RadioListTile<ThemeMode>(
              title: const Text('라이트 모드'),
              value: ThemeMode.light,
              groupValue: appState.themeMode,
              onChanged: (ThemeMode? value) {
                appState.setThemeMode(value ?? ThemeMode.light);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크 모드'),
              value: ThemeMode.dark,
              groupValue: appState.themeMode,
              onChanged: (ThemeMode? value) {
                appState.setThemeMode(value ?? ThemeMode.dark);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('시스템 설정 따르기'),
              value: ThemeMode.system,
              groupValue: appState.themeMode,
              onChanged: (ThemeMode? value) {
                appState.setThemeMode(value ?? ThemeMode.system);
              },
            ),
          ],
        ),
      ),
    );
  }
}
