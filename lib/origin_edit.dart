import 'package:flutter/material.dart';

class OriginEditPage extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onSave;

  const OriginEditPage({
    Key? key,
    required this.initialText,
    required this.onSave,
  }) : super(key: key);

  @override
  _OriginEditPageState createState() => _OriginEditPageState();
}

class _OriginEditPageState extends State<OriginEditPage> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveEditedText() {
    widget.onSave(_textController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('텍스트 수정'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEditedText,
          ),
        ],
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '수정할 텍스트를 입력하세요',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveEditedText,
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
