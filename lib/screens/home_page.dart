import 'package:flutter/material.dart';
import 'package:prevent_rental_fraud/widgets/news_list_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.newsLinks,
    required this.onPageChange
  });
  final List<String> newsLinks;
  final Function(int) onPageChange;

  @override
  createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  bool isPressedAIService1 = false;
  bool isDelayed = false;
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
              left: screenWidth * 0.25,
              top: screenHeight * startPosition + 240,
              child: Column(
                spacing: 10,
                children: [
                  Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isPressedAIService1 = !isPressedAIService1;
                          });
                          if(!isDelayed) {
                            Future.delayed(Duration(milliseconds: 200), () {
                              setState(() {
                                isDelayed = !isDelayed;
                              });
                            });
                          } else{
                            setState(() {
                              isDelayed = !isDelayed;
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          shape: isPressedAIService1 ? RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))) 
                              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          backgroundColor: Colors.white,
                          fixedSize: Size(screenWidth * 0.5, 60),
                        ),
                        child: Text(
                          '깡통 전세 체크',     //이 부분에 사용자 접근성을 고려한 AI간략화 기능이 있으면 좋을듯
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
                      AnimatedContainer(
                        clipBehavior: Clip.hardEdge,
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: screenWidth * 0.5,
                        height: isPressedAIService1 ? 180 : 0,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30)),
                          ),
                        ),
                        duration: Duration(milliseconds: 300),
                        child: Column(
                          children: [
                            for(int i = 0; i < 5; i++)
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 100 * i + 100),
                                child: isDelayed ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                          spacing: 5,
                                          children: [
                                            Icon(Icons.circle, size: 5),
                                            Text("$i 번째 체크 리스트")
                                          ]
                                      ),
                                      Icon(Icons.check_circle, size: 15, color: Colors.green)
                                    ]
                                ) : SizedBox.shrink(),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: (){
                      widget.onPageChange(1);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      fixedSize: WidgetStateProperty.all(Size(screenWidth * 0.5, 60)),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '챗봇 상담 하러 가기',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1,
                              )
                          ),
                          Icon(Icons.arrow_right_alt)
                        ],
                      )
                    )
                  ),
                ],
              )
            ),
            // Positioned(
            //   left: screenWidth * 0.25,
            //   top: screenHeight * startPosition + 430,
            //   child:
            // ),
          ],
        ),
      ),
    );
  }
}
