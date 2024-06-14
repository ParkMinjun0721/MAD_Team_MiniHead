import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FolderPage extends StatefulWidget {
  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDocSnapshot = await _firestore.collection('users').doc(user.uid).get();
        if (userDocSnapshot.exists) {
          List<String> collections = List<String>.from(userDocSnapshot['collections']);
          setState(() {
            _folders = collections;
            _isLoading = false;
          });
        } else {
          print('User document does not exist');
          setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folders'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_folders[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FolderContentsPage(folderName: _folders[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FolderContentsPage extends StatelessWidget {
  final String folderName;

  const FolderContentsPage({Key? key, required this.folderName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final CollectionReference folderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection(folderName);

    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: folderRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final String fileName = item['fileName'] ?? '';
              final String imageUrl = item['imageUrl'] ?? '';
              final String recognizedText = item['recognizedText'] ?? '';
              final String extractedText = item['extractedText'] ?? '';

              return ListTile(
                leading: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 50, color: Colors.grey),
                title: Text(fileName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsPage(
                        title: fileName,
                        imageUrl: imageUrl,
                        recognizedText: recognizedText,
                        extractedText: extractedText,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ItemDetailsPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String recognizedText;
  final String extractedText;

  const ItemDetailsPage({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.recognizedText,
    required this.extractedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Icon(Icons.image, size: 100, color: Colors.grey),
              const SizedBox(height: 16.0),
              Text(
                'Extracted Text',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(extractedText, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16.0),
              Text(
                'Recognized Text',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(recognizedText, style: TextStyle(fontSize: 16)),

            ],
          ),
        ),
      ),
    );
  }
}
