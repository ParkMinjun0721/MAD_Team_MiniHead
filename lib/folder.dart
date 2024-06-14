import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('test2')
            .get();
        List<String> folders = snapshot.docs.map((doc) => doc.id).toList();
        setState(() {
          _folders = folders;
          _isLoading = false;
        });
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
          ).animate().fadeIn(duration: 300.ms).moveY(begin: 20, end: 0);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
      ),
      body: Center(
        child: Text('Contents of $folderName'),
      ),
    );
  }
}
