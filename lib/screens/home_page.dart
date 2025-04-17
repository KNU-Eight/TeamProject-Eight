import 'package:flutter/material.dart';
import 'package:prevent_rental_fraud/widgets/news_list_builder.dart';



class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.newsLinks
  });
  final List<String> newsLinks;
  @override
  createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double startPosition = 0.06;
    return Scaffold(
      body: Container(
        width: screenWidth, // 동적 너비
        height: screenHeight, // 동적 높이
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: const Color(0xFFF0F0F0)),
        child: Stack(
          children: [
            Positioned(   // 상단 노란색 영역
              left: 0,
              top: 0,
              child: Container(
                width: screenWidth,
                height: screenHeight * startPosition + 150,
                decoration: BoxDecoration(color: const Color(0xFFFFDA62)),
              ),
            ),
            Positioned(
              left: screenWidth * startPosition,
              top: screenHeight * startPosition + 90,
              child: Text(
                '어려운 뉴스도 요약해서 쉽게 알려드려요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF707070),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * startPosition,
              top: screenHeight * startPosition + 60,
              child: Text(
                '최근 뉴스 ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * startPosition,
              top: screenHeight * startPosition,
              child: Text(
                '홈',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
            Positioned(   //뉴스 컨테이너
              left: screenWidth * startPosition,
              top: screenHeight * startPosition + 110,
              child: NewsListBuilder(
                newsLinks: widget.newsLinks,
              )
            ),
            Positioned(
              left: screenWidth,
              top: screenHeight * startPosition + 150,
              child: Container(
                width: 162,
                height: 77,
                decoration: ShapeDecoration(
                  color: const Color(0xFFD9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * startPosition,
              top: screenHeight * startPosition + 200,
              child: Text(
                'AI 서비스',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * startPosition,
              top: screenHeight * startPosition + 240,
              child: Container(
                width: screenWidth * 0.88,
                height: 200,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '깡통 전세 판단',     //이 부분에 사용자 접근성을 고려한 AI간략화 기능이 있으면 좋을듯
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 347,
              top: 51,
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(5),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Stack(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
