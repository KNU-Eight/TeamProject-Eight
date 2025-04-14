import 'package:flutter/material.dart';
import 'package:prevent_rental_fraud/screens/home_page.dart';
import 'package:prevent_rental_fraud/screens/intro_page.dart';
import 'package:prevent_rental_fraud/widgets/navigation_bar_item.dart';

//Bottom Navigation Items
const _bnbItems = [
  BNBIcon(
    enabledIcon: Icons.home,
    disabledIcon: Icons.home_outlined,
    label:'Home',
    index: 0,
  ),
  BNBIcon(
    enabledIcon: Icons.map,
    disabledIcon: Icons.map_outlined,
    label:'Map',
    index: 1,
  ),
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
  late TabController _tabController; // TabController 추가
  int _pageIndex = 0;    //현재 페이지 인덱스
  late List<Widget> _pages;

  @override
  Widget build(BuildContext context) {
    _pages = [HomePage(newsLinks: widget.newsLinks,), IntroPage()];
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