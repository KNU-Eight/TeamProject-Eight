import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/chat_bubble.dart';
import '../widgets/message_container.dart';

class ChatbotPage extends StatefulWidget{
  const ChatbotPage({super.key});

  @override
  createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>{
  List<ChatBubble> _bubbles = [];
  final StreamController<List<ChatBubble>> _streamController = StreamController<List<ChatBubble>>();
  final TextEditingController _textEditingController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 인스턴스
  User? _currentUser; // 현재 Firebase 사용자

  bool _isLoading = false;

  void _addMessageToChat(String message, bool isMe) async {
    if (message.isNotEmpty) {
      _bubbles.add(ChatBubble(isMe: isMe, text: message));
      _streamController.add(List.from(_bubbles));

      if (_currentUser != null) { // 사용자 로그인 여부 확인
        await _firestore.collection('chat_histories')
            .doc(_currentUser!.uid)
            .collection('messages')
            .add({
          'text': message,
          'isMe': isMe,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> _loadChatHistory() async { // 채팅 기록 로드 함수
    _currentUser = FirebaseAuth.instance.currentUser; // 현재 사용자 가져오기
    if (_currentUser != null) { // 사용자 로그인 여부 확인
      try {
        final querySnapshot = await _firestore.collection('chat_histories')
            .doc(_currentUser!.uid)
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .get();

        _bubbles.clear(); // 기존 버블 지우기
        for (var doc in querySnapshot.docs) { // 문서 반복
          final data = doc.data();
          _bubbles.add(ChatBubble(isMe: data['isMe'], text: data['text'])); // 데이터에서 채팅 버블 추가
        }
        if (_bubbles.isEmpty) { // 이력이 없으면 초기 메시지 추가
          _addMessageToChat('안녕하세요! 전세사기 예방 및 해결 도우미 집피티입니다. \n 무엇을 도와드릴까요?', false); // 초기 메시지 추가
        }
        _streamController.add(List.from(_bubbles));
      } catch (e) {
        print("채팅 기록 로드 중 오류: $e");
        _addMessageToChat("채팅 기록을 불러오는 데 실패했습니다.", false); // 채팅에 오류 메시지 추가
      }
    } else {
      _addMessageToChat('안녕하세요! 전세사기 예방 및 해결 도우미 집피티입니다. \n 무엇을 도와드릴까요?', false); // 로그인하지 않은 경우 초기 메시지 추가
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChatHistory(); // 초기화 시 채팅 기록 로드
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _streamController.close();
    super.dispose();
  }

  // 메시지 전송, FastAPI 호출, 응답 처리 함수
  Future<void> _sendMessage() async {
    final inputText = _textEditingController.text.trim();

    if (inputText.isEmpty || _isLoading) {
      return;
    }

    _addMessageToChat(inputText, true);
    _textEditingController.clear();

    setState(() {
      _isLoading = true;
    });

    // FastAPI 백엔드 호출
    // 웹에서 테스트 시 'http://localhost:8000' 사용
    // Android 에뮬레이터 시 'http://10.0.2.2:8000/chat' 사용
    // final String backendUrl = "http://localhost:8000/chat";

    final String backendUrl = "http://10.0.2.2:8000/chat";

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'prompt': inputText, // 사용자의 입력 텍스트를 백엔드로 전송
        }),
      );

      String llmResponseText;
      if (response.statusCode == 200) {
        // LLM 응답 성공 시
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        llmResponseText = responseData['response'] ?? "LLM 응답 형식이 잘못되었습니다.";
      } else {
        // LLM 응답 에러 시
        llmResponseText = "LLM 응답 에러: ${response.statusCode}\n${response.body}";
        print("FastAPI Error: ${response.statusCode}\nResponse Body: ${response.body}");
      }

      _addMessageToChat(llmResponseText, false);

    } catch (e) {
      print("Error calling LLM backend: $e");
      _addMessageToChat("LLM 백엔드 호출 실패: ${e.toString()}", false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('LLM 응답 받기 실패: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /*
  void sendMessage(String message, bool isMe){
    _bubbles.add(ChatBubble(isMe: isMe, text: message));
    _streamController.add(_bubbles);
  }
  */

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
                height: screenHeight * 0.93 - 166,
                top: screenHeight * startPosition + 60,
                child:Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
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
              Positioned(
                bottom: screenHeight * 0.01,
                left: screenWidth * startPosition,
                width: screenWidth * 0.8,
                child:SizedBox(
                  height: 40,
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
              ),
              Positioned(
                  bottom: screenHeight * 0.01,
                  left: screenWidth * startPosition + screenWidth * 0.8 + 8,
                  child:GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      width: 40, // 아이콘 버튼 크기
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : Theme.of(context).primaryColor, // 로딩 상태에 따라 색 변경
                        shape: BoxShape.circle, // 원형 배경
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox( // 로딩 중일 때 인디케이터 표시
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Icon( // 로딩 중이 아닐 때 보내기 아이콘 표시
                          Icons.send,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
              )
            ]
          )
        ),
      )
    );
  }

}