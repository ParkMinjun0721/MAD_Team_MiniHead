import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class FolderContentsPage extends StatefulWidget {
  final String folderName;

  const FolderContentsPage({Key? key, required this.folderName}) : super(key: key);

  @override
  _FolderContentsPageState createState() => _FolderContentsPageState();
}

class _FolderContentsPageState extends State<FolderContentsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
        List<Map<String, dynamic>> files = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;  // Add document ID for later use
          return data;
        }).toList();

        Provider.of<AppState>(context, listen: false).setFiles(files); // Update AppState

        setState(() {
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

  void _deleteFile(String docId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection(widget.folderName)
            .doc(docId)
            .delete();

        Provider.of<AppState>(context, listen: false).deleteFile(docId); // Update AppState

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일이 삭제되었습니다')),
        );
      }
    } catch (e) {
      print('Error deleting file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 삭제에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final files = Provider.of<AppState>(context).files;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: files[index]['imageUrl'] != null
                ? GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageDetailPage(imageUrl: files[index]['imageUrl']),
                  ),
                );
              },
              child: Hero(
                tag: files[index]['imageUrl'],
                child: Image.network(
                  files[index]['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            )
                : Icon(Icons.image, size: 50),
            title: Text(files[index]['fileName'] ?? 'File ${index + 1}'),
            subtitle: Text('Timestamp: ${DateTime.fromMillisecondsSinceEpoch(files[index]['timestamp'])}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteFile(files[index]['id']);
              },
            ),
            onTap: () async {
              final updatedFile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileDetailPage(fileData: files[index], folderName: widget.folderName),
                ),
              );

              if (updatedFile != null) {
                Provider.of<AppState>(context, listen: false).updateFile(updatedFile); // Update AppState
              }
            },
          );
        },
      ),
    );
  }
}

class FileDetailPage extends StatefulWidget {
  final Map<String, dynamic> fileData;
  final String folderName;

  const FileDetailPage({Key? key, required this.fileData, required this.folderName}) : super(key: key);

  @override
  _FileDetailPageState createState() => _FileDetailPageState();
}

class _FileDetailPageState extends State<FileDetailPage> {
  late Map<String, dynamic> fileData;

  @override
  void initState() {
    super.initState();
    fileData = widget.fileData;
  }

  void _updateFileData(Map<String, dynamic> updatedFile) {
    setState(() {
      fileData = updatedFile;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('복사되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileData['fileName'] ?? 'File Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedFile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditFilePage(fileData: fileData, folderName: widget.folderName),
                ),
              );

              if (updatedFile != null) {
                _updateFileData(updatedFile);
                Provider.of<AppState>(context, listen: false).updateFile(updatedFile); // Update AppState
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Image:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              fileData['imageUrl'] != null
                  ? GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageDetailPage(imageUrl: fileData['imageUrl']),
                    ),
                  );
                },
                child: Hero(
                  tag: fileData['imageUrl'],
                  child: Image.network(fileData['imageUrl']),
                ),
              )
                  : Text('No image available'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Extracted Text:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(fileData['extractedText'] ?? 'No text available'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(fileData['extractedText'] ?? 'No text available'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recognized Text:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(fileData['recognizedText'] ?? 'No recognized text available'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(fileData['recognizedText'] ?? 'No recognized text available'),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageDetailPage extends StatelessWidget {
  final String imageUrl;

  const ImageDetailPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

class EditFilePage extends StatefulWidget {
  final Map<String, dynamic> fileData;
  final String folderName;

  const EditFilePage({Key? key, required this.fileData, required this.folderName}) : super(key: key);

  @override
  _EditFilePageState createState() => _EditFilePageState();
}

class _EditFilePageState extends State<EditFilePage> {
  late TextEditingController _fileNameController;
  late TextEditingController _extractedTextController;
  late TextEditingController _recognizedTextController;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: widget.fileData['fileName']);
    _extractedTextController = TextEditingController(text: widget.fileData['extractedText']);
    _recognizedTextController = TextEditingController(text: widget.fileData['recognizedText']);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _extractedTextController.dispose();
    _recognizedTextController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(widget.folderName)
            .doc(widget.fileData['id'])
            .update({
          'fileName': _fileNameController.text,
          'extractedText': _extractedTextController.text,
          'recognizedText': _recognizedTextController.text,
        });

        Map<String, dynamic> updatedFile = {
          ...widget.fileData,
          'fileName': _fileNameController.text,
          'extractedText': _extractedTextController.text,
          'recognizedText': _recognizedTextController.text,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일이 수정되었습니다')),
        );

        Navigator.pop(context, updatedFile);
      }
    } catch (e) {
      print('Error updating file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 수정에 실패했습니다: $e')),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('복사되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('파일 수정'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _fileNameController,
                decoration: InputDecoration(labelText: '파일명'),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Extracted Text:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(_extractedTextController.text),
                  ),
                ],
              ),
              TextField(
                controller: _extractedTextController,
                maxLines: null,
                decoration: InputDecoration(labelText: '추출된 텍스트'),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recognized Text:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(_recognizedTextController.text),
                  ),
                ],
              ),
              TextField(
                controller: _recognizedTextController,
                maxLines: null,
                decoration: InputDecoration(labelText: '인식된 텍스트'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
