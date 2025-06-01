import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';

class MyInfoPage extends StatefulWidget{
  const MyInfoPage({super.key});

  @override
  createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage>{
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // FirebaseFirestore 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn 인스턴스

  // 대화 기록 삭제 함수
  Future<void> _deleteChatHistory() async {
    final user = _auth.currentUser; // 현재 로그인된 사용자 가져오기
    if (user == null) { // 사용자가 로그인되어 있지 않다면
      _showSnackBar('로그인이 필요합니다.'); // 스낵바 메시지 표시
      return;
    }

    // 사용자에게 확인 메시지 표시
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('대화 기록 삭제'),
          content: Text('모든 대화 기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final messagesRef = _firestore.collection('chat_histories').doc(user.uid).collection('messages'); // messages 컬렉션 참조
        final batch = _firestore.batch();

        final querySnapshot = await messagesRef.get();
        for (var doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        _showSnackBar('대화 기록이 성공적으로 삭제되었습니다.');
      } catch (e) {
        print('대화 기록 삭제 오류: $e');
        _showSnackBar('대화 기록 삭제 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 회원 탈퇴 함수
  Future<void> _deleteAccount() async {
    final user = _auth.currentUser; // 현재 로그인된 사용자 가져오기
    if (user == null) { // 사용자가 로그인되어 있지 않다면
      _showSnackBar('로그인이 필요합니다.'); // 스낵바 메시지 표시
      return;
    }

    // 사용자에게 확인 메시지 표시
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원 탈퇴'),
          content: Text('정말 회원 탈퇴를 하시겠습니까? 모든 정보가 삭제되며 이 작업은 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('탈퇴'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // 1. Firestore에서 사용자 관련 데이터 삭제
        // chat_histories의 해당 사용자 문서 삭제
        await _firestore.collection('chat_histories').doc(user.uid).delete(); // 채팅 기록 문서 삭제
        // users 컬렉션의 해당 사용자 문서 삭제 (로그인 페이지에서 사용자 정보를 저장하는 경우)
        await _firestore.collection('users').doc(user.uid).delete(); // 사용자 정보 문서 삭제

        // 2. Firebase Authentication에서 사용자 계정 삭제
        // GoogleSignIn이 활성화된 경우 signOut을 먼저 호출하여 연결을 끊음
        await _googleSignIn.signOut(); // Google 계정 연결 해제
        await user.delete(); // Firebase 사용자 계정 삭제

        _showSnackBar('회원 탈퇴가 성공적으로 완료되었습니다.'); // 성공 메시지 표시

        // 회원 탈퇴 후 로그인 페이지로 이동
        Navigator.of(context).pushAndRemoveUntil( // 현재 스택을 모두 제거하고 로그인 페이지로 이동
          MaterialPageRoute(builder: (context) => LoginPage(newsLinks: const [])), // LoginPage로 이동
              (Route<dynamic> route) => false,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') { // 최근 로그인 필요 오류
          // 사용자가 최근에 로그인하지 않은 경우 재인증 필요
          _showSnackBar('보안을 위해 재로그인이 필요합니다. 다시 로그인 후 시도해주세요.'); // 재로그인 안내
          // 로그아웃 후 로그인 페이지로 이동하여 재로그인 유도
          await _auth.signOut(); // 로그아웃
          await _googleSignIn.signOut(); // Google 계정 연결 해제
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage(newsLinks: const [])),
                (Route<dynamic> route) => false,
          );
        } else {
          print('회원 탈퇴 오류: $e'); // 오류 출력
          _showSnackBar('회원 탈퇴 중 오류가 발생했습니다: $e'); // 오류 메시지 표시
        }
      } catch (e) {
        print('회원 탈퇴 오류: $e'); // 오류 출력
        _showSnackBar('회원 탈퇴 중 오류가 발생했습니다: $e'); // 오류 메시지 표시
      }
    }
  }

  // 스낵바를 표시하는 헬퍼 함수
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
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
                                      itemCount: 2, // 항목 수를 2개로 변경 (대화기록 삭제, 회원탈퇴)
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return TextButton(
                                            onPressed: _deleteChatHistory, // 대화 기록 삭제 함수 연결
                                            style: TextButton.styleFrom(
                                              alignment: Alignment.centerLeft, // 텍스트를 왼쪽으로 정렬
                                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 15), // 패딩 조정
                                              foregroundColor: Colors.black, // 텍스트 색상
                                              textStyle: TextStyle(fontSize: 16), // 텍스트 스타일
                                            ),
                                            child: Text('대화 기록 삭제'),
                                          );
                                        } else {
                                          return TextButton(
                                            onPressed: _deleteAccount, // 회원 탈퇴 함수 연결
                                            style: TextButton.styleFrom(
                                              alignment: Alignment.centerLeft, // 텍스트를 왼쪽으로 정렬
                                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 15), // 패딩 조정
                                              foregroundColor: Colors.red, // 텍스트 색상 (경고)
                                              textStyle: TextStyle(fontSize: 16), // 텍스트 스타일
                                            ),
                                            child: Text('회원 탈퇴'),
                                          );
                                        }
                                      },
                                      separatorBuilder: (context, index) => Divider(indent: screenWidth * 0.05, endIndent: screenWidth * 0.05, thickness: 0.5), // 구분선 추가 및 인덴트 적용
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