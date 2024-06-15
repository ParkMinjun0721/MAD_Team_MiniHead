import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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
        DocumentSnapshot userDocSnapshot = await _firestore.collection('users').doc(user.uid).get();
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

  Future<void> _deleteFolder(String folderName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);

        // Delete all documents in the folder in Firestore
        QuerySnapshot folderSnapshot = await userDocRef.collection(folderName).get();
        for (QueryDocumentSnapshot doc in folderSnapshot.docs) {
          await doc.reference.delete();
        }

        // Delete folder document
        QuerySnapshot folderDocSnapshot = await userDocRef.collection('Folder').where('folder', isEqualTo: folderName).get();
        for (DocumentSnapshot ds in folderDocSnapshot.docs) {
          await ds.reference.delete();
        }

        // Delete files in Firebase Storage
        firebase_storage.ListResult result = await firebase_storage.FirebaseStorage.instance.ref().child(folderName).listAll();
        for (firebase_storage.Reference ref in result.items) {
          await ref.delete();
        }

        // Update the collections array in user document
        DocumentSnapshot userDocSnapshot = await userDocRef.get();
        if (userDocSnapshot.exists) {
          List<String> collections = List<String>.from(userDocSnapshot['collections']);
          collections.remove(folderName);
          await userDocRef.update({'collections': collections});
        }

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
                // edit 기능은 나중에 구현하겠음
                // IconButton(
                //   icon: Icon(Icons.edit),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => EditFolderPage(
                //           initialFolderName: _folders[index],
                //           onSave: (String editedFolderName) {
                //             setState(() {
                //               _folders[index] = editedFolderName;
                //             });
                //           },
                //         ),
                //       ),
                //     );
                //   },
                // ),
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
