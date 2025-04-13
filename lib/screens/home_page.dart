import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
                height: screenHeight * 0.22 + 38.5,
                decoration: BoxDecoration(color: const Color(0xFFFFDA62)),
              ),
            ),
            Positioned(
              left: screenWidth * 0.06,
              top: screenHeight * 0.195,
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
              left: screenWidth * 0.06,
              top: screenHeight * 0.16,
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
              left: screenWidth * 0.06,
              top: screenHeight * 0.08,
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
              left: screenWidth * 0.06,
              top: screenHeight * 0.22,
              child: Container(
                width: 176,
                height: 77,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Positioned(   //뉴스 컨테이너
              left: screenWidth * 0.1 + 176,
              top: screenHeight * 0.22,
              child: Container(
                width: 176,
                height: 77,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Positioned(
              left: screenWidth,
              top: screenHeight * 0.22 + 38.5,
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
              left: 22,
              top: 332,
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
              left: 22,
              top: 382,
              child: Container(
                width: 176,
                height: 248,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 39,
              top: 461,
              child: Text(
                '전세사기 피해 예방',
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
            Positioned(
              left: 239,
              top: 459,
              child: Text(
                '전세사기 피해 대응',
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
