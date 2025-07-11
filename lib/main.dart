import 'package:flutter/material.dart';
import 'ListOne.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
);

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
      home: TravelListScreen(),

    );
  }
}

class TravelListScreen extends StatefulWidget {
  @override
  _TravelListState createState() => _TravelListState();
}

class _TravelListState extends State<TravelListScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _autoLogin();
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
        child: Text('로그인', style: TextStyle(fontSize: 16, color: Colors.black)),
      );
    } else {
      return SizedBox(
        child: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') onLogout();
          },
          itemBuilder: (context) =>
          [
            PopupMenuItem<String>(
              value: 'logout',
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '로그아웃',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
          child: GestureDetector(
            onTap: null,
            child: Text(
              userName!,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
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
            Text(
              '여행 일정 리스트',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
            loginButton(),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '일정이 없습니다.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                Future.delayed(const Duration(seconds: 2), () {
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
            const Text(
              'AI가 만들어주는 여행 일정',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: '일정'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '정보'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: '안내'),
        ],
      ),
    );
  }
}
