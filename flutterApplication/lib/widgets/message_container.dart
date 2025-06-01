import 'package:flutter/material.dart';

import 'chat_bubble.dart';

class MessageContainer extends StatelessWidget{


  final List<ChatBubble> bubbles;

  const MessageContainer({
    super.key,
    required this.bubbles
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 40),
        itemCount: bubbles.length,
        itemBuilder: (context, index){
          return Padding(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: bubbles[index]
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 20),
      )
    );
  }

}