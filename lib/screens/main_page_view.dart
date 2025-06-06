import 'package:flutter/material.dart';
import 'package:prevent_rental_fraud/screens/home_page.dart';
import 'package:prevent_rental_fraud/screens/my_info_page.dart';
import 'package:prevent_rental_fraud/widgets/navigation_bar_item.dart';

import 'chatbot_page.dart';

//Bottom Navigation Items
const _bnbItems = [
  BNBIcon(
    enabledIcon: Icons.home,
    disabledIcon: Icons.home_outlined,
    label:'홈',
    index: 0,
  ),
  BNBIcon(
    enabledIcon: Icons.chat,
    disabledIcon: Icons.chat_outlined,
    label:'챗봇',
    index: 1,
  ),
  BNBIcon(
    enabledIcon: Icons.person,
    disabledIcon: Icons.person_outlined,
    label:'내 정보',
    index: 2,
  )
];

class MainPageView extends StatefulWidget{
  const MainPageView({
    super.key,
    required this.newsLinks
  });
  final List<String> newsLinks;
  @override
  createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView>{
  final _pageController = PageController();
  int _pageIndex = 0;    //현재 페이지 인덱스
  late List<Widget> _pages;
  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    _pages = [HomePage(newsLinks: widget.newsLinks,), ChatbotPage(), MyInfoPage()];
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        onTap:(int index){
          setState((){
            _pageIndex = index;
            _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
          });
        },
        currentIndex: _pageIndex,
        items: _bnbItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(_pageIndex == item.index ? item.enabledIcon:item.disabledIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}