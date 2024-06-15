import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'navigatinbar.dart';
import 'app_state.dart';
import 'addimage.dart'; // addimage.dart 파일 import
import 'settings.dart'; // settings.dart 파일 import
import 'help.dart'; // help.dart 파일 import
import 'origin.dart'; // origin.dart 파일 import
import 'profile.dart'; // profile.dart 파일 import
import 'folder.dart'; // folder.dart 파일 import
import 'FolderContentsPage.dart'; // FolderContentsPage import

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AddImage _addImage = AddImage(); // AddImage 인스턴스 생성
  List<Map<String, dynamic>> _recentItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentItems();
  }

  Future<void> _fetchRecentItems() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch all folders
        QuerySnapshot folderSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('Folder')
            .get();

        List<Map<String, dynamic>> allItems = [];

        for (var folderDoc in folderSnapshot.docs) {
          String folderName = folderDoc['folder'];

          // Fetch items from each folder
          QuerySnapshot itemSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(folderName)
              .orderBy('timestamp', descending: true)
              .limit(2)
              .get();

          for (var itemDoc in itemSnapshot.docs) {
            Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;
            itemData['folder'] = folderName;  // Add folder name to item data
            itemData['id'] = itemDoc.id;  // Add document ID to item data
            allItems.add(itemData);
          }
        }

        // Sort all items by timestamp and get the top 2 recent items
        allItems.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        _recentItems = allItems.take(2).toList();

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching recent items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('사진 가져오기'),
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.camera_alt, size: 50),
                      onPressed: () async {
                        final image = await _addImage.pickImageFromCamera();
                        if (image != null) {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OriginPage(image: image),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          print('No image selected from camera.');
                        }
                      },
                    ),
                    const Text('카메라'),
                  ],
                ).animate().fadeIn(duration: 500.ms).scale(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.photo_library, size: 50),
                      onPressed: () async {
                        final image = await _addImage.pickImageFromGallery();
                        if (image != null) {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OriginPage(image: image),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          print('No image selected from gallery.');
                        }
                      },
                    ),
                    const Text('갤러리'),
                  ],
                ).animate().fadeIn(duration: 500.ms).scale(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      bottomNavigationBar: bottomNavigationBar(appState.selectedIndex, (index) {
        appState.setSelectedIndex(index);
        setState(() {});
      }),
      backgroundColor: Colors.lightBlue[50], // 배경색 설정
      body: _getSelectedPage(appState.selectedIndex),
    );
  }

  Widget _getSelectedPage(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return FolderPage(); // 폴더 페이지로 이동
      case 2:
        return ProfilePage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildHomePage() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        // 검색바
        TextField(
          decoration: InputDecoration(
            hintText: '검색',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.grey[300],
          ),
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 16.0),
        // 아이콘 버튼들
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.grey,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _showImageSourceDialog,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text('스캔'),
              ],
            ).animate().fadeIn(duration: 500.ms).scale(),
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.grey,
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // 설정 버튼을 눌렀을 때 SettingsPage로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text('설정'),
              ],
            ).animate().fadeIn(duration: 500.ms).scale(),
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.grey,
                  child: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      // 도움말 버튼을 눌렀을 때 HelpPage로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text('도움말'),
              ],
            ).animate().fadeIn(duration: 500.ms).scale(),
          ],
        ),
        const SizedBox(height: 16.0),
        // 최근 섹션
        const Text(
          '최근',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 16.0),
        // 최근 아이템들
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: _recentItems.map((item) {
            final String title = item['fileName'] ?? 'No Title';
            final int timestamp = item['timestamp'] ?? 0;
            final String date = DateTime.fromMillisecondsSinceEpoch(timestamp).toString();
            final String imageUrl = item['imageUrl'] ?? '';
            final String folderName = item['folder'] ?? '';
            final String itemId = item['id'] ?? '';

            return RecentItem(
              title: title,
              date: date,
              imageUrl: imageUrl,
              folderName: folderName,
              itemId: itemId,
            ).animate().fadeIn(duration: 500.ms).slide();
          }).toList(),
        ),
      ],
    );
  }
}

class RecentItem extends StatelessWidget {
  final String title;
  final String date;
  final String imageUrl;
  final String folderName;
  final String itemId;

  const RecentItem({
    Key? key,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.folderName,
    required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical margin between items
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0), // Increase border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Lighter shadow
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              imageUrl.isNotEmpty
                  ? Hero(
                tag: imageUrl,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailPage(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0), // Add border radius to image
                    child: Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
                  : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8.0), // Add border radius to placeholder
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent, // Change text color
                      ),
                      overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                    ),
                    const SizedBox(height: 4.0), // Add space between title and date
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Add border radius to button
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FolderContentsPage(folderName: folderName),
                      ),
                    );
                  },
                  child: const Text('파일 위치로 이동'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Add border radius to button
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FileDetailPage(
                          folderName: folderName,
                          itemId: itemId,
                        ),
                      ),
                    );
                  },
                  child: const Text('자세히 보기'),
                ),
              ],
            ),
          ),
        ],
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
      appBar: AppBar(
        title: Text('Image Detail'),
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

class FileDetailPage extends StatelessWidget {
  final String folderName;
  final String itemId;

  const FileDetailPage({Key? key, required this.folderName, required this.itemId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('File Detail'),
        ),
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    final DocumentReference fileRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(folderName)
        .doc(itemId);

    return Scaffold(
      appBar: AppBar(
        title: Text('File Detail'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: fileRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('File not found'));
          } else {
            final Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            final String title = data['fileName'] ?? 'No Title';
            final String recognizedText = data['recognizedText'] ?? 'No Recognized Text';
            final String extractedText = data['extractedText'] ?? 'No Extracted Text';
            final String imageUrl = data['imageUrl'] ?? '';

            return Padding(
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
                      'Title',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(title, style: TextStyle(fontSize: 16)),
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
            );
          }
        },
      ),
    );
  }
}
