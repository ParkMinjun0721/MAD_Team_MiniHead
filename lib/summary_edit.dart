import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class SummaryEditPage extends StatefulWidget {
  final String recognizedText;

  const SummaryEditPage({Key? key, required this.recognizedText}) : super(key: key);

  @override
  _SummaryEditPageState createState() => _SummaryEditPageState();
}

class _SummaryEditPageState extends State<SummaryEditPage> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.recognizedText);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Save the changes to AppState and go back
    Provider.of<AppState>(context, listen: false).setSummaryText(_textEditingController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('텍스트 수정하기'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textEditingController,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: '수정할 텍스트',
          ),
        ),
      ),
    );
  }
}
