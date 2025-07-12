// main.dart
import 'package:flutter/material.dart';
import 'ListOne.dart'; // TravelListScreen, TravelFormScreen
import 'search.dart';  // SearchScreen
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '여행 일정 생성',
      debugShowCheckedModeBanner: false,
      // MainScreen에 globalKey를 연결합니다.
      home: MainScreen(key: MainScreen.globalKey),
    );
  }
}

class MainScreen extends StatefulWidget {
  // GlobalKey를 static 멤버로 추가하여 다른 곳에서 이 State에 접근할 수 있게 합니다.
  static final GlobalKey<_MainScreenState> globalKey = GlobalKey();

  const MainScreen({Key? key}) : super(key: key); // 생성자에 key를 받도록 수정합니다.

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? userName;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _autoLogin();

    _screens = [
      const TravelListScreen(), // 단일 인스턴스 유지
      const SearchScreen(),
      const Center(child: Text('안내 화면')),
    ];
  }

  // 외부에서 탭 인덱스를 변경할 수 있는 메서드를 추가합니다.
  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _autoLogin() async {
    final account = await _googleSignIn.signInSilently();
    if (account != null) {
      setState(() {
        userName = account.displayName ?? account.email;
      });
    }
  }

  Future<void> onLogin() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        setState(() {
          userName = account.displayName ?? account.email;
        });

        // ✅ 백엔드에 로그인 정보 전송
        final response = await http.post(
          Uri.parse('https://port-0-railway-backend-mczsqk1b8f7c8972.sel5.cloudtype.app/auth/google'), // 백엔드 주소 넣기!
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': account.email,
            'name': account.displayName ?? account.email,
          }),
        );

        if (response.statusCode == 200) {
          print('✅ 서버 응답: ${response.body}');
        } else {
          print('❌ 서버 오류: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('에러: $error');
    }
  }

  Future<void> onLogout() async {
    await _googleSignIn.signOut();
    setState(() {
      userName = null;
    });
  }

  Widget loginButton() {
    if (userName == null) {
      return GestureDetector(
        onTap: onLogin,
        child: const Text('로그인', style: TextStyle(fontSize: 16, color: Colors.black)),
      );
    } else {
      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'logout') onLogout();
        },
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'logout',
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('로그아웃', style: TextStyle(fontSize: 14, color: Colors.black)),
          ),
        ],
        child: Text(userName!, style: const TextStyle(fontSize: 16, color: Colors.black)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('여행 일정 생성', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
            loginButton(),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: '일정'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '정보'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: '안내'),
        ],
      ),
    );
  }
}

class TravelListScreen extends StatelessWidget {
  const TravelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('일정이 없습니다.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pop(context); // 로딩 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TravelFormScreen()),
                );
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
            ),
            child: const Text('일정 추가', style: TextStyle(color: Colors.blue)),
          ),
          const SizedBox(height: 10),
          const Text('AI가 만들어주는 여행 일정', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}