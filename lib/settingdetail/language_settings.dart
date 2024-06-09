import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/app_state.dart';
import '/l10n/app_localizations.dart';
import '/main.dart';  // MyApp 클래스를 가져오기 위해 import

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.languageSettings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RadioListTile<String>(
              title: Text(AppLocalizations.of(context)!.korean),
              value: 'ko',
              groupValue: appState.locale?.languageCode,
              onChanged: (String? value) {
                if (value != null) {
                  appState.setLocale(value);
                  // 로케일을 즉시 반영
                  MyApp.setLocale(context, Locale(value));
                }
              },
            ),
            RadioListTile<String>(
              title: Text(AppLocalizations.of(context)!.english),
              value: 'en',
              groupValue: appState.locale?.languageCode,
              onChanged: (String? value) {
                if (value != null) {
                  appState.setLocale(value);
                  // 로케일을 즉시 반영
                  MyApp.setLocale(context, Locale(value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
