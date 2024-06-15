import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  Future<String> _loadImage(String path) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(path);
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error loading image: $e');
      return '';
    }
  }

  void _showHelpDialog(BuildContext context, String title, List<HelpPageItem> pages) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: SizedBox(
            height: 350, // Adjust height as needed
            width: double.maxFinite,
            child: HelpDialogContent(pages: pages),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<HelpPageItem>> _loadHelpItems(List<HelpPageItem> items) async {
    List<HelpPageItem> loadedItems = [];
    for (var item in items) {
      String imageUrl = await _loadImage(item.imagePath);
      loadedItems.add(HelpPageItem(item.description, imageUrl));
    }
    return loadedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          FutureBuilder<List<HelpPageItem>>(
            future: _loadHelpItems([
              HelpPageItem('프로필 페이지 상단의 로그아웃 버튼을 눌러 로그아웃할 수 있습니다.', 'logout1.png'),
              HelpPageItem('또한 설정의 하단에 로그아웃 버튼이 있습니다.', 'logout2.png'),
              HelpPageItem('로그아웃 후에는 로그인 페이지로 이동합니다.', 'logout3.png'),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading help items');
              } else {
                return Column(
                  children: [
                    _buildHelpListTile(
                      context,
                      '로그아웃 방법',
                      snapshot.data!,
                    ),
                    const Divider(),
                  ],
                );
              }
            },
          ),
          FutureBuilder<List<HelpPageItem>>(
            future: _loadHelpItems([
              HelpPageItem('스캔 버튼을 눌러 카메라를 실행합니다.', 'scan1.png'),
              HelpPageItem('카메라를 사용하여 이미지를 찍습니다.', 'scan2.png'),
              HelpPageItem('갤러리에서 이미지를 선택할 수도 있습니다.', 'scan3.png'),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading help items');
              } else {
                return Column(
                  children: [
                    _buildHelpListTile(
                      context,
                      '스캔 방법',
                      snapshot.data!,
                    ),
                    const Divider(),
                  ],
                );
              }
            },
          ),
          FutureBuilder<List<HelpPageItem>>(
            future: _loadHelpItems([
              HelpPageItem('설정 버튼에서 테마 설정을 클릭합니다.', 'theme1.png'),
              HelpPageItem('라이트 모드와, 다크 모드를 설정 할 수 있습니다.', 'theme2.png'),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading help items');
              } else {
                return Column(
                  children: [
                    _buildHelpListTile(
                      context,
                      '앱 테마 변경',
                      snapshot.data!,
                    ),
                    const Divider(),
                  ],
                );
              }
            },
          ),
          FutureBuilder<List<HelpPageItem>>(
            future: _loadHelpItems([
              HelpPageItem('요약 페이지에서 대화하기 버튼을 누릅니다.', 'chat1.png'),
              HelpPageItem('AI와의 대화를 통해 사용자에 니즈에 맞는 답변을 받을 수 있습니다.', 'chat2.png'),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading help items');
              } else {
                return Column(
                  children: [
                    _buildHelpListTile(
                      context,
                      'AI와의 대화 기능',
                      snapshot.data!,
                    ),
                    const Divider(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHelpListTile(BuildContext context, String title, List<HelpPageItem> pages) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
      trailing: Icon(Icons.arrow_forward, color: Colors.blueAccent),
      onTap: () {
        _showHelpDialog(context, title, pages);
      },
    );
  }
}

class HelpPageItem {
  final String description;
  final String imagePath; // 이미지 경로 추가

  HelpPageItem(this.description, this.imagePath);
}

class HelpDialogContent extends StatefulWidget {
  final List<HelpPageItem> pages;

  const HelpDialogContent({Key? key, required this.pages}) : super(key: key);

  @override
  _HelpDialogContentState createState() => _HelpDialogContentState();
}

class _HelpDialogContentState extends State<HelpDialogContent> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.pages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => HeroImagePage(
                      tag: widget.pages[index].imagePath,
                      imageUrl: widget.pages[index].imagePath,
                    ),
                  ));
                },
                child: Column(
                  children: <Widget>[
                    Hero(
                      tag: widget.pages[index].imagePath,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // Placeholder for image
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: widget.pages[index].imagePath.isNotEmpty
                            ? Image.network(widget.pages[index].imagePath, fit: BoxFit.cover)
                            : Center(
                          child: Icon(Icons.image, size: 100, color: Colors.grey[600]), // Placeholder icon
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.pages[index].description,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Page ${_currentPage + 1} of ${widget.pages.length}',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}

class HeroImagePage extends StatelessWidget {
  final String tag;
  final String imageUrl;

  const HeroImagePage({Key? key, required this.tag, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: tag,
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
