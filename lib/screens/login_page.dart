import 'package:flutter/material.dart';
import 'main_page_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({
    super.key,
    required this.newsLinks
  });
  final List<String> newsLinks;
  @override
  State<LoginPage> createState() => _LoginState();

}

class _LoginState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // FirebaseFirestore 인스턴스

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _signInWithGoogle() async { // Google 로그인 함수
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn(); // Google 로그인 시작
      if (googleUser == null) {
        // 사용자가 로그인을 취소함
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication; // Google 인증 정보 가져오기
      final credential = GoogleAuthProvider.credential( // Google 인증 자격 증명 생성
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential); // Google 자격 증명으로 로그인

      // 새 사용자라면 Firestore에 사용자 데이터 저장
      if (userCredential.additionalUserInfo?.isNewUser == true) { // 새 사용자 여부 확인
        await _firestore.collection('users').doc(userCredential.user!.uid).set({ // Firestore에 사용자 데이터 저장
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'photoUrl': userCredential.user!.photoURL,
          'createdAt': Timestamp.now(),
        });
      }
      _navigateToMainPage(); // 메인 페이지로 이동
    } on FirebaseAuthException catch (e) { // Firebase 인증 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 로그인 실패: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 로그인 오류: $e')),
      );
    }
  }

  void _navigateToMainPage() { // 메인 페이지로 이동하는 함수
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SafeArea(child: MainPageView(newsLinks: widget.newsLinks)))
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.25,
              width: screenWidth,
              child: Text(
                '로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.4,
              left: screenWidth * 0.1,
              width: screenWidth * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell( // Google 로그인 버튼
                    onTap: _signInWithGoogle, // Google 로그인 시 탭
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      decoration: ShapeDecoration(
                        color: Colors.red, // Google 색상
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: Colors.red, // Google 색상
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.g_mobiledata, size: 24, color: Colors.white), // Google 아이콘
                          SizedBox(width: 8),
                          Text(
                            'Google 계정으로 로그인', // Google 로그인 텍스트
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}