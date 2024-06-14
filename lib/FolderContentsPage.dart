import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FolderContentsPage extends StatefulWidget {
  final String folderName;

  const FolderContentsPage({Key? key, required this.folderName}) : super(key: key);

  @override
  _FolderContentsPageState createState() => _FolderContentsPageState();
}

class _FolderContentsPageState extends State<FolderContentsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection(widget.folderName)
            .orderBy('timestamp', descending: true)
            .get();
        List<Map<String, dynamic>> files = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        setState(() {
          _files = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching files: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('File ${index + 1}'),
            subtitle: Text('Timestamp: ${DateTime.fromMillisecondsSinceEpoch(_files[index]['timestamp'])}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileDetailPage(fileData: _files[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FileDetailPage extends StatelessWidget {
  final Map<String, dynamic> fileData;

  const FileDetailPage({Key? key, required this.fileData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Extracted Text:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(fileData['extractedText'] ?? 'No text available'),
            SizedBox(height: 16),
            Text(
              'Image URL:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(fileData['imageUrl'] ?? 'No image URL available'),
          ],
        ),
      ),
    );
  }
}
