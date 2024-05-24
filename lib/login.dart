import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'home.dart'; // 홈 화면 import
import 'app_state.dart'; // 앱 상태 import

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
    await GoogleSignIn().signOut();  // 현재 로그인한 계정을 로그아웃
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Firestore에 사용자 정보 저장
    User? user = userCredential.user;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'uid': user.uid,
        'status_message': 'I promise to take the test honestly before GOD.',
      }, SetOptions(merge: true)); // merge: true로 설정하면 기존 데이터가 덮어쓰여지지 않습니다.
    }
    return userCredential;
  }

  // 익명 로그인
  Future<UserCredential> signInAnonymously() async {
    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();

    // Firestore에 사용자 정보 저장
    User? user = userCredential.user;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'status_message': 'I promise to take the test honestly before GOD.',
      }, SetOptions(merge: true));
    }
    return userCredential;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                const SizedBox(height: 16.0),
                const Text('SHRINE'),
              ],
            ),
            const SizedBox(height: 120.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await signInWithGoogle();
                  User? user = userCredential.user;
                  if (user != null) {
                    print('로그인 성공: ${user.email}');
                    appState.setUser(user); // 앱 상태에 사용자 설정
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(title: 'Flutter Demo Home Page'), // 홈 화면으로 이동
                      ),
                    );
                  } else {
                    print('로그인 실패');
                  }
                } catch (e) {
                  print('로그인 오류: $e');
                }
              },
              child: Text('Sign in with Google'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await signInAnonymously();
                  User? user = userCredential.user;
                  print("Signed in with temporary account.");
                  if (user != null) {
                    appState.setUser(user); // 앱 상태에 사용자 설정
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(title: 'Flutter Demo Home Page'), // 홈 화면으로 이동
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  switch (e.code) {
                    case "operation-not-allowed":
                      print("Anonymous auth hasn't been enabled for this project.");
                      break;
                    default:
                      print("Unknown error.");
                  }
                }
              },
              child: Text('Sign in with Guest'),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}
