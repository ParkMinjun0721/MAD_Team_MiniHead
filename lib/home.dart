import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'navigatinbar.dart';
import 'app_state.dart';
import 'addimage.dart'; // addimage.dart 파일 import
import 'settings.dart'; // settings.dart 파일 import
import 'help.dart'; // help.dart 파일 import
import 'origin.dart'; // origin.dart 파일 import
import 'profile.dart'; // profile.dart 파일 import
import 'folder.dart'; // folder.dart 파일 import

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AddImage _addImage = AddImage(); // AddImage 인스턴스 생성

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
        RecentItem(
          title: 'Title',
          date: '2024-03-29 21:03',
        ).animate().fadeIn(duration: 500.ms).slide(),
        const SizedBox(height: 16.0),
        RecentItem(
          title: 'Title',
          date: '2024-03-29 21:03',
        ).animate().fadeIn(duration: 500.ms).slide(),
      ],
    );
  }
}

class RecentItem extends StatelessWidget {
  final String title;
  final String date;

  const RecentItem({
    Key? key,
    required this.title,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {},
                child: const Text('공유'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('원본 보기'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('요약본 보기'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
