import 'package:flutter/material.dart';

class MyInfoPage extends StatefulWidget{
  const MyInfoPage({super.key});

  @override
  createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage>{

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double startPosition = 0.06;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 키보드 닫기 이벤트
        },
        child: Scaffold(
          body: Container(
              width: screenWidth, // 동적 너비
              height: screenHeight, // 동적 높이
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: const Color(0xFFF0F0F0)),
              child: Stack(
                children: [
                  Positioned(
                    left: screenWidth * startPosition,
                    top: screenHeight * startPosition,
                    child: Text(
                      '내 정보',
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
                  Positioned.fill( // Positioned를 추가하여 하단을 채움
                    top: screenHeight * startPosition + 50, // 첫 번째 Positioned 다음부터 시작
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded( // 빈 공간을 채우도록 설정
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: 5,
                                    itemBuilder: (context, index) {
                                      return TextButton(
                                        onPressed: () {  },
                                        child: Text('항목 $index'),
                                      );
                                    },
                                    separatorBuilder: (context, index) => Divider(indent: 0.8), // 구분선 추가
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
          ),
        )
    );
  }

}
