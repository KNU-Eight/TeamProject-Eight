import 'package:flutter/material.dart';
import 'draw_bubble.dart';

class ChatBubble extends StatefulWidget{    //말풍성
  const ChatBubble({
    super.key,
    required this.isMe,
    required this.text,
  });

  final bool isMe;    //나의 채팅인지 챗봇 채팅인지
  final String text;  //채팅 내용
  @override
  createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>{
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.88,
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft, // 오른쪽 또는 왼쪽 정렬
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: DrawBubble(text: widget.text, isMe: widget.isMe),
        ),
      )
    );
  }
}