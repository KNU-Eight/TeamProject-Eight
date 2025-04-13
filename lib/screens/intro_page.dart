import 'package:flutter/material.dart';
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _IntroPage();
  }
}
class _IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth, // 동적 너비
        height: screenHeight, // 동적 높이
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 97,
          children: [
            SizedBox(
              width: 188,
              height: 46,
              child: Text(
                '집피티',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            Text(
              '안전한 집을 위한 가장 확실한 선택',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            Container(
              width: 412,
              height: 412,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://placehold.co/412x412"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}