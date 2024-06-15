import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mad_team_minihead/sum_up_page.dart';
import 'origin_edit.dart';  // 추가
import 'package:flutter/services.dart';

class OriginPage extends StatefulWidget {
  final File image;

  const OriginPage({Key? key, required this.image}) : super(key: key);

  @override
  _OriginPageState createState() => _OriginPageState();
}

class _OriginPageState extends State<OriginPage> {
  String _recognizedText = '텍스트 인식을 진행 중입니다...';

  @override
  void initState() {
    super.initState();
    _scanText();
  }

  Future<void> _scanText() async {
    try {
      final inputImage = InputImage.fromFile(widget.image);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      setState(() {
        _recognizedText = recognizedText.text;
      });
    } catch (e) {
      setState(() {
        _recognizedText = '텍스트 인식에 실패했습니다: $e';
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('복사되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.9; // Adjust the multiplier as needed

    return Scaffold(
      appBar: AppBar(
        title: const Text('원본'),
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '원본',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                _recognizedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                AnimatedIconButton(
                  label: '수정하기',
                  icon: Icons.edit,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OriginEditPage(
                          initialText: _recognizedText,
                          onSave: (String editedText) {
                            setState(() {
                              _recognizedText = editedText;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                AnimatedIconButton(
                  label: '복사하기',
                  icon: Icons.copy,
                  onTap: () => _copyToClipboard(_recognizedText),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SumupPage(
                extractedText: _recognizedText,
                imageFile: widget.image, // Pass the image file to SumupPage
              ),
            ),
          );
        },
        child: const Icon(Icons.arrow_forward),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const AnimatedIconButton({
    Key? key,
    required this.label,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isButtonPressed = true),
      onTapUp: (_) => setState(() => _isButtonPressed = false),
      onTapCancel: () => setState(() => _isButtonPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: _isButtonPressed ? Colors.grey[400] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: <Widget>[
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isButtonPressed ? 0.5 : 1.0,
              child: Icon(widget.icon, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 8.0),
            Text(widget.label),
          ],
        ),
      ),
    );
  }
}
