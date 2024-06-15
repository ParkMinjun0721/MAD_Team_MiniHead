import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'dart:io';

import 'summary_page.dart';
import 'summary_edit.dart';
import 'package:mad_team_minihead/openai_service.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'home.dart';  // home.dart 파일 import

class SumupPage extends StatefulWidget {
  final String extractedText;
  final File imageFile;

  const SumupPage({Key? key, required this.extractedText, required this.imageFile}) : super(key: key);

  @override
  _SumupPageState createState() => _SumupPageState();
}

class _SumupPageState extends State<SumupPage> {
  final _formKey = GlobalKey<FormState>();
  String _folderName = ''; // Variable to store folder name
  String _fileName = ''; // Variable to store file name
  List<String> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scanText();
    _fetchFolders();
  }

  Future<void> _scanText() async {
    try {
      String initMessage = widget.extractedText;
      String response = await OpenAIService().createModel(initMessage);

      Provider.of<AppState>(context, listen: false).setSummaryText(response);
    } catch (e) {
      Provider.of<AppState>(context, listen: false).setSummaryText('텍스트 인식에 실패했습니다: $e');
    }
  }

  Future<void> _fetchFolders() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDocSnapshot.exists) {
          List<String> collections = List<String>.from(userDocSnapshot['collections']);
          setState(() {
            _folders = collections;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching folders: $e');
      setState(() {
        _isLoading = false;
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
      await _showFolderSelectionDialog();
      // Check if _folderName is set
      if (_folderName.isNotEmpty) {
        // Show dialog to get file name
        await _showFileNameDialog();
        // Check if _fileName is set
        if (_fileName.isNotEmpty) {
          try {
            // Upload image to Firebase Storage
            firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance
                .ref()
                .child('$_folderName/$_fileName.jpg');

            firebase_storage.UploadTask uploadTask = storageRef.putFile(widget.imageFile);

            // Wait for upload to complete
            await uploadTask.whenComplete(() => null);

            // Get download URL
            String imageUrl = await storageRef.getDownloadURL();

            // Save data to Firestore with the chosen folder name
            await addCollectionWithMetadata(FirebaseAuth.instance.currentUser!.uid, _folderName, {
              'extractedText': widget.extractedText,
              'recognizedText': Provider.of<AppState>(context, listen: false).summaryText, // Add recognizedText
              'imageUrl': imageUrl,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'userId': FirebaseAuth.instance.currentUser!.uid,
              'fileName': _fileName, // Add fileName
            });

            // Navigate back to home page after saving
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home')),
                  (Route<dynamic> route) => false,
            );
          } catch (e) {
            print('Data save error: $e');
            // Handle the error, e.g., show a message to the user
          }
        }
      }
    }
  }

  Future<bool> _isFolderNameUnique(String folderName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('Folder')
          .where('folder', isEqualTo: folderName)
          .get();
      return snapshot.docs.isEmpty;
    }
    return false;
  }

  Future<void> addCollectionWithMetadata(String userId, String collectionName, Map<String, dynamic> data) async {
    // 상위 문서 참조
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // 하위 컬렉션에 데이터 추가
    await userDocRef.collection(collectionName).add(data);

    // 상위 문서의 메타데이터 필드 업데이트
    await userDocRef.set({
      'collections': FieldValue.arrayUnion([collectionName])
    }, SetOptions(merge: true));
  }

  Future<void> _showFolderSelectionDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String newFolderName = '';

        return AlertDialog(
          title: Text('폴더를 선택하거나 새 폴더를 만드세요'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isLoading)
                ..._folders.map((folder) => ListTile(
                  title: Text(folder),
                  onTap: () {
                    setState(() {
                      _folderName = folder;
                    });
                    Navigator.of(context).pop();
                  },
                )),
              TextField(
                onChanged: (value) {
                  newFolderName = value;
                },
                decoration: InputDecoration(hintText: '새 폴더명 입력'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('저장'),
              onPressed: () async {
                if (newFolderName.isNotEmpty) {
                  // Check if the new folder name is unique
                  if (await _isFolderNameUnique(newFolderName)) {
                    setState(() {
                      _folderName = newFolderName;
                    });

                    // Add new folder to the list
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("Folder")
                        .add({
                      'folder': _folderName,
                    });

                    Navigator.of(context).pop();
                  } else {
                    _showErrorDialog('폴더명이 중복되었습니다.');
                  }
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFileNameDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String newFileName = '';

        return AlertDialog(
          title: Text('파일명을 입력하세요'),
          content: TextField(
            onChanged: (value) {
              newFileName = value;
            },
            decoration: InputDecoration(hintText: '파일명 입력'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('저장'),
              onPressed: () {
                if (newFileName.isNotEmpty) {
                  setState(() {
                    _fileName = newFileName;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
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
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('요약'),
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView
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
                  appState.summaryText.isNotEmpty ? appState.summaryText : '텍스트 인식 중...',
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
                          builder: (context) => SummaryEditPage(recognizedText: appState.summaryText.isNotEmpty ? appState.summaryText : '텍스트 인식 중...'),
                        ),
                      );
                    },
                  ),
                  AnimatedIconButton(
                    label: '복사하기',
                    icon: Icons.copy,
                    onTap: () => _copyToClipboard(appState.summaryText.isNotEmpty ? appState.summaryText : '텍스트 인식 중...'),
                  ),
                  AnimatedIconButton(
                    label: '대화하기',
                    icon: Icons.comment,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SummaryPage(extractedText: appState.summaryText.isNotEmpty ? appState.summaryText : '텍스트 인식 중...'),
                        ),
                      );
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
