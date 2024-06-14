import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildHelpListTile(
            context,
            '로그아웃 방법',
            [
              HelpPageItem('프로필 페이지 상단의 로그아웃 버튼을 눌러 로그아웃할 수 있습니다.'),
              HelpPageItem('로그아웃 후에는 로그인 페이지로 이동합니다.'),
            ],
          ),
          const Divider(),
          _buildHelpListTile(
            context,
            '스캔 방법',
            [
              HelpPageItem('스캔 버튼을 눌러 카메라를 실행합니다.'),
              HelpPageItem('카메라를 사용하여 이미지를 찍습니다.'),
              HelpPageItem('갤러리에서 이미지를 선택할 수도 있습니다.'),
            ],
          ),
          const Divider(),
          _buildHelpListTile(
            context,
            '공유 방법',
            [
              HelpPageItem('스캔한 텍스트를 선택합니다.'),
              HelpPageItem('공유하기 버튼을 눌러 다른 앱으로 텍스트를 공유합니다.'),
            ],
          ),
          const Divider(),
          _buildHelpListTile(
            context,
            '기타 문의사항',
            [
              HelpPageItem('앱 사용 중 문제가 발생하면 고객센터에 문의해 주세요.'),
              HelpPageItem('고객센터는 앱 설정 메뉴에서 찾을 수 있습니다.'),
            ],
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

  HelpPageItem(this.description);
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
              return Column(
                children: <Widget>[
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Placeholder for image
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Icon(Icons.image, size: 100, color: Colors.grey[600]), // Placeholder icon
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.pages[index].description,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
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
