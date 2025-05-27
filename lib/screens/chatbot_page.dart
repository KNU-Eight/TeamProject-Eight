import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_container.dart';

class ChatbotPage extends StatefulWidget{
  const ChatbotPage({super.key});

  @override
  createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>{
  String _inputText = '';
  late List<ChatBubble> _bubbles;
  late final StreamController<List<ChatBubble>> _streamController;
  final TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _bubbles = [];
    _streamController = StreamController<List<ChatBubble>>.broadcast(); // 여기서 초기화
  }

  void sendMessage(String message, bool isMe){
    _bubbles.add(ChatBubble(isMe: isMe, text: message));
    _streamController.add(_bubbles);
  }
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
                  '챗봇',
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
              Positioned(
                width: screenWidth,
                bottom: 0,
                child:Column(
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        height: screenHeight * 0.93 - 226,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: StreamBuilder<List<ChatBubble>>(
                                stream: _streamController.stream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return Center(child: Text('대화 내용이 없습니다.'));
                                  return MessageContainer(
                                    bubbles: snapshot.data!,
                                  );
                                },
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Colors.white,
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 40,
                            width: screenWidth * 0.8,
                            child:TextField(
                              controller: _textEditingController,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1,
                              ),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  hintText: '내용을 입력해 주세요.',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    height: 1,
                                  )
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              _inputText = _textEditingController.text;
                              if(_inputText != ''){
                                sendMessage(_inputText, true);
                                sendMessage('안녕하세요! 전세사기 예방 및 해결 도우미 집피티입니다. \n 무엇을 도와드릴까요?', false);
                                _textEditingController.clear();
                              }
                            },
                            child: Icon(Icons.send, size: 40),
                          )
                        ],
                      )
                    )

                  ],
                )
              ),
            ]
          )
        ),
      )
    );
  }

}
