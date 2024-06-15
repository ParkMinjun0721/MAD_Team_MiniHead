import 'package:flutter/material.dart';
import 'openai_service.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class SummaryPage extends StatefulWidget {
  final String extractedText;

  const SummaryPage({Key? key, required this.extractedText}) : super(key: key);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    setState(() {
      _isLoading = true;
    });

    String initMessage = widget.extractedText;
    OpenAIService openAIService = OpenAIService();
    String response = await openAIService.createModel(initMessage);

    setState(() {
      _messages.add({'role': 'user', 'content': initMessage});
      _messages.add({'role': 'assistant', 'content': response});
      _isLoading = false;
    });

    // Update AppState with the initial message and response
    Provider.of<AppState>(context, listen: false).setSummaryText(response);
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': _controller.text});
      _isLoading = true;
    });

    OpenAIService openAIService = OpenAIService();
    String response = await openAIService.createModel(_controller.text);

    setState(() {
      _messages.add({'role': 'assistant', 'content': response});
      _isLoading = false;
    });

    _controller.clear();

    // Update AppState with the new message and response
    Provider.of<AppState>(context, listen: false).setSummaryText(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with OpenAI'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['role'] == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message['role'] == 'user'
                            ? Colors.blue[100]
                            : Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(message['content'] ?? ''),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Ask something...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
