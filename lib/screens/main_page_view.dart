import 'package:flutter/material.dart';
import 'package:prevent_rental_fraud/screens/home_page.dart';
import 'package:prevent_rental_fraud/screens/intro_page.dart';

class BNBIcon{    //Icon을 Enabled와 Disabled로 나누어 동적으로 할당하기 위한 클래스
  final IconData enabledIcon;
  final IconData disabledIcon;
  final String label;
  final int index;

  const BNBIcon({
    required this.enabledIcon,
    required this.disabledIcon,
    required this.label,
    required this.index,
  });
}
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
  const MainPageView({super.key});

  @override
  createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView>{
  final _pageController = PageController();
  int _pageIndex = 0;    //현재 페이지 인덱스
  List<Widget> _pages = [HomePage(), IntroPage()];
  List<Icon> _bottomNavigationBarIcons = [Icon(Icons.home_filled), Icon(Icons.map_outlined)];
  @override
  Widget build(BuildContext context) {
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