import 'package:flutter/material.dart';

class DrawBubble extends StatelessWidget{
  final String text;
  final bool isMe;
  const DrawBubble({
    super.key,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PaintBubble(color: Colors.white, isMe: isMe),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          height: 1.2,
        )
      )
    );
  }
}

class PaintBubble extends CustomPainter{
  const PaintBubble({
    required this.color,
    required this.isMe,
  });
  final Color color;
  final bool isMe;
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final aiBorderPaint = Paint()
      ..color = const Color(0xFFFFDA62)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final double padding = 8.0;
    final isMePath = Path()
      ..moveTo(-padding, size.height - 4 + padding) // 시작점
      ..lineTo(-padding, 4 - padding)               // 왼쪽 상단
      ..arcToPoint(Offset(4 - padding, -padding), radius: Radius.circular(8))   //왼쪽 상단 모서리
      ..lineTo(size.width - 8 + padding, -padding)  //오른쪽 상단
      ..arcToPoint(Offset(size.width - 4 + padding, 4 - padding), radius: Radius.circular(8))   //오른쪽 상단 모서리
      ..lineTo(size.width - 4 + padding, size.height - 6 + padding)   //오른쪽 하단
      ..lineTo(size.width + padding, size.height + padding)   //말꼬리
      ..lineTo(4 - padding, size.height + padding)    //왼쪽 하단
      ..arcToPoint(Offset(-padding, size.height - 4 + padding), radius: Radius.circular(8))   //왼쪽 하단 모서리
      ..close();    //패스 닫기
    final inversionMatrix = Matrix4.identity()
      ..scale(-1.0, 1.0); // 좌우 반전
    final translationMatrix = Matrix4.translationValues(-size.width, 0, 0);   //반전으로 이동된 위치 복원
    final combinedMatrix = inversionMatrix..multiply(translationMatrix);      //두 변환 배열 병합
    final notIsMePath = isMePath.transform(combinedMatrix.storage);           //반전 및 좌표 이동

    if(isMe) {
      canvas.drawPath(isMePath, borderPaint);
    } else{
      canvas.drawPath(notIsMePath, aiBorderPaint);
    }
  }

  @override
  bool shouldRepaint(PaintBubble oldDelegate) {
    return false;
  }

}