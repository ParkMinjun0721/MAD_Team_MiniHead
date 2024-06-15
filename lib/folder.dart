import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'FolderContentsPage.dart';
import 'app_state.dart';
import 'folder_edit.dart';

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
            .collection('Folder')
            .get();
        List<String> folders = snapshot.docs.map((doc) => doc['folder'] as String).toList();
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

  void _deleteFolder(String folderName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete all documents in the folder
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection(folderName)
            .get();
        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }

        // Delete the folder document
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('Folder')
            .where('folder', isEqualTo: folderName)
            .get()
            .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        });

        setState(() {
          _folders.remove(folderName);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('폴더가 삭제되었습니다')),
        );
      }
    } catch (e) {
      print('Error deleting folder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('폴더 삭제에 실패했습니다: $e')),
      );
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditFolderPage(
                          initialFolderName: _folders[index],
                          onSave: (String editedFolderName) {
                            setState(() {
                              _folders[index] = editedFolderName;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteFolder(_folders[index]);
                  },
                ),
              ],
            ),
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
