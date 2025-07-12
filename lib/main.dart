import 'package:flutter/material.dart';
import 'ListOne.dart'; // TravelListScreen, TravelFormScreen
import 'search.dart';  // SearchScreen
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'two.dart';

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
      home: MainScreen(key: MainScreen.globalKey),
    );
  }
}

class MainScreen extends StatefulWidget {
  static final GlobalKey<_MainScreenState> globalKey = GlobalKey();
  const MainScreen({Key? key}) : super(key: key);

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
      TravelListScreen(userName: userName ?? 'guest'),
      const SearchScreen(),
      const Center(child: Text('안내 화면')),
    ];
  }

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
        final response = await http.post(
          Uri.parse('https://port-0-railway-backend-mczsqk1b8f7c8972.sel5.cloudtype.app/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': account.email,
            'name': account.displayName ?? account.email,
          }),
        );
        if (response.statusCode != 200) {
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

class TravelListScreen extends StatefulWidget {
  final String userName;
  const TravelListScreen({super.key, required this.userName});

  @override
  State<TravelListScreen> createState() => _TravelListScreenState();
}

class _TravelListScreenState extends State<TravelListScreen> {
  List<dynamic> schedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    try {
      final encodedUser = Uri.encodeComponent(widget.userName.toLowerCase());
      final response = await http.get(Uri.parse(
          'https://port-0-railway-backend-mczsqk1b8f7c8972.sel5.cloudtype.app/schedule/user/$encodedUser'));

      if (response.statusCode == 200) {
        setState(() {
          schedules = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('일정이 없습니다.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TravelFormScreen()),
                ).then((_) => fetchSchedules());
              },
              child: const Text('일정 추가', style: TextStyle(color: Colors.blue)),
            ),
            const SizedBox(height: 10),
            const Text('AI가 만들어주는 여행 일정', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length + 1,
      itemBuilder: (context, index) {
        if (index == schedules.length) {
          return Center(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TravelFormScreen()),
                ).then((_) => fetchSchedules());
              },
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
              child: const Text('일정 추가', style: TextStyle(color: Colors.blue)),
            ),
          );
        }

        final schedule = schedules[index];

        return ListTile(
          title: Text('${schedule['startDate']} ~ ${schedule['endDate']}'),
          subtitle: Text('${schedule['tags'].join(', ')} | ${schedule['people']}명'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TravelScheduleScreen(
                  startDate: DateTime.parse(schedule['startDate']),
                  endDate: DateTime.parse(schedule['endDate']),
                  tags: List<String>.from(schedule['tags']),
                  people: schedule['people'],
                  relations: List<String>.from(schedule['relations']),
                  request: schedule['request'],
                  scheduleData: Map<int, List<Map<String, String>>>.from(
                    (schedule['scheduleData'] as Map).map(
                          (key, value) => MapEntry(
                        int.parse(key),
                        List<Map<String, String>>.from(
                          (value as List).map<Map<String, String>>(
                                (item) => Map<String, String>.from(item),
                          ),
                        ),
                      ),
                    ),
                  ),
                  userName: widget.userName,
                  scheduleId: schedule['_id'], // 여기에 ID 넣기 (MongoDB라면 _id)
                ),
              ),
            ).then((_) => fetchSchedules());
          },
        );
      },
    );
  }
}
