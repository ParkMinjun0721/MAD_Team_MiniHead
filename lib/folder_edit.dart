import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditFolderPage extends StatefulWidget {
  final String initialFolderName;
  final ValueChanged<String> onSave;

  const EditFolderPage({Key? key, required this.initialFolderName, required this.onSave}) : super(key: key);

  @override
  _EditFolderPageState createState() => _EditFolderPageState();
}

class _EditFolderPageState extends State<EditFolderPage> {
  late TextEditingController _folderNameController;

  @override
  void initState() {
    super.initState();
    _folderNameController = TextEditingController(text: widget.initialFolderName);
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update all documents in the folder
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(widget.initialFolderName)
            .get();
        for (DocumentSnapshot doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection(_folderNameController.text)
                .doc(doc.id)
                .set(data);
            await doc.reference.delete();
          }
        }

        // Update the folder document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('Folder')
            .where('folder', isEqualTo: widget.initialFolderName)
            .get()
            .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.update({'folder': _folderNameController.text});
          }
        });

        widget.onSave(_folderNameController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('폴더가 수정되었습니다')),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating folder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('폴더 수정에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('폴더 수정'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _folderNameController,
          decoration: InputDecoration(labelText: '폴더명'),
        ),
      ),
    );
  }
}
