import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

import 'summary_page.dart';
import 'package:mad_team_minihead/openai_service.dart';

class SumupPage extends StatefulWidget {
  final String extractedText;
  final File imageFile;

  const SumupPage({Key? key, required this.extractedText, required this.imageFile})
      : super(key: key);

  @override
  _SumupPageState createState() => _SumupPageState();
}

class _SumupPageState extends State<SumupPage> {
  String _recognizedText = '텍스트 인식을 진행 중입니다...';
  final _formKey = GlobalKey<FormState>();
  late String _folderName; // Variable to store folder name

  @override
  void initState() {
    super.initState();
    _scanText();
  }

  Future<void> _scanText() async {
    try {
      String initMessage = widget.extractedText;
      String response = await OpenAIService().createModel(initMessage);

      setState(() {
        _recognizedText = response;
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

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      // Show dialog to get folder name
      await _showFolderNameDialog();
      // Check if _folderName is set
      if (_folderName.isNotEmpty) {
        try {
          // Upload image to Firebase Storage
          firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance
              .ref()
              .child('$_folderName/${DateTime.now().millisecondsSinceEpoch}.jpg');

          firebase_storage.UploadTask uploadTask = storageRef.putFile(widget.imageFile);

          // Wait for upload to complete
          await uploadTask.whenComplete(() => null);

          // Get download URL
          String imageUrl = await storageRef.getDownloadURL();

          // Save data to Firestore with the chosen folder name

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection(_folderName)
              .add({
            'extractedText': widget.extractedText,
            'imageUrl': imageUrl,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'userId': FirebaseAuth.instance.currentUser!.uid,
          });



          Navigator.pop(context); // Navigate back after saving
        } catch (e) {
          print('Data save error: $e');
          // Handle the error, e.g., show a message to the user
        }
      }
    }
  }

  Future<void> _showFolderNameDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('폴더명을 입력하세요'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                _folderName = value;
              });
            },
            decoration: InputDecoration(hintText: '폴더명'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('저장'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요약'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '요약',
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
                    AnimatedIconButton(
                      label: '대화하기',
                      icon: Icons.comment,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SummaryPage(extractedText: _recognizedText),
                          ),
                        );
                      },
                    ),
                    AnimatedIconButton(
                      label: '복사하기',
                      icon: Icons.copy,
                      onTap: () => _copyToClipboard(_recognizedText),
                    ),
                    AnimatedIconButton(
                      label: '공유하기',
                      icon: Icons.share,
                      onTap: () {
                        // 공유하기 기능 구현
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveData,
                    child: const Text('저장하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
