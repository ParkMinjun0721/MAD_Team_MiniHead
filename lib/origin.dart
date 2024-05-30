import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'summary.dart'; // summary.dart 파일 import

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('원본'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  _buildButton(context, '저장하기'),
                  _buildButton(context, '복사하기'),
                  _buildButton(context, '공유하기'),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SummaryPage(extractedText: _recognizedText),
            ),
          );
        },
        child: const Icon(Icons.arrow_forward),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildButton(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            color: Colors.grey,
          ),
          const SizedBox(height: 8.0),
          Text(label),
        ],
      ),
    );
  }
}
