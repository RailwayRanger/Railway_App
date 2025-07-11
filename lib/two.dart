import 'dart:math';
import 'package:flutter/material.dart';

class TravelScheduleScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<String> tags;
  final int people;
  final List<String> relations;
  final String request;

  const TravelScheduleScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.tags,
    required this.people,
    required this.relations,
    required this.request,
  });

  @override
  State<TravelScheduleScreen> createState() => _TravelScheduleScreenState();
}

class _TravelScheduleScreenState extends State<TravelScheduleScreen> {
  Map<int, List<Map<String, String>>> scheduleData = {};
  final Random random = Random();

  int? selectedDay;
  int? selectedIndex;

  final Map<String, List<String>> regionMap = {
    '서울': ['서울 경복궁', '서울 남산타워'],
    '부산': ['부산 해운대', '부산 감천문화마을'],
    '제주': ['제주 성산일출봉', '제주 우도'],
    '강원': ['강릉 안목해변', '강릉 경포대', '속초 설악산', '속초 대포항', '양양 서피비치'],
    '경북': ['경주 불국사', '경주 첨성대', '포항 호미곶', '울산 대왕암공원'],
    '전라': ['전주 한옥마을', '여수 해상케이블카', '여수 오동도', '군산 근대역사박물관'],
    '충청': ['대전 성심당', '태안 꽃지해수욕장', '무주 덕유산 리조트'],
    '경남': ['통영 동피랑마을', '진해 군항제 벚꽃길', '남해 독일마을', '합천 해인사'],
    '대구': ['대구 근대골목'],
    '경기': ['춘천 남이섬'],
  };

  final Map<String, List<String>> neighborRegions = {
    '서울': ['경기', '강원'],
    '경기': ['서울', '강원', '충청'],
    '강원': ['경기', '경북'],
    '경북': ['강원', '경남', '대구'],
    '대구': ['경북', '경남'],
    '경남': ['대구', '경북', '전라'],
    '전라': ['경남', '충청'],
    '충청': ['경기', '전라'],
    '부산': ['경남'],
    '제주': ['제주'],
  };

  final Map<String, List<String>> placeTags = {
    '서울 경복궁': ['문화/역사', '도시'],
    '서울 남산타워': ['감성', '도시'],
    '부산 해운대': ['자연', '힐링'],
    '부산 감천문화마을': ['감성', '문화/역사'],
    '강릉 안목해변': ['자연', '감성', '힐링'],
    '강릉 경포대': ['자연', '힐링'],
    '속초 설악산': ['자연', '액티비티'],
    '속초 대포항': ['자연', '감성'],
    '경주 불국사': ['문화/역사'],
    '경주 첨성대': ['문화/역사'],
    '전주 한옥마을': ['문화/역사', '감성'],
    '여수 해상케이블카': ['감성', '액티비티'],
    '여수 오동도': ['자연', '힐링'],
    '군산 근대역사박물관': ['문화/역사'],
    '제주 성산일출봉': ['자연', '액티비티'],
    '제주 우도': ['자연', '힐링'],
    '대전 성심당': ['도시', '맛집'],
    '태안 꽃지해수욕장': ['자연', '힐링'],
    '무주 덕유산 리조트': ['자연', '액티비티'],
    '통영 동피랑마을': ['감성'],
    '진해 군항제 벚꽃길': ['감성', '자연'],
    '남해 독일마을': ['감성', '힐링'],
    '합천 해인사': ['문화/역사'],
    '춘천 남이섬': ['자연', '감성'],
    '포항 호미곶': ['자연'],
    '울산 대왕암공원': ['자연'],
    '대구 근대골목': ['문화/역사'],
  };

  @override
  void initState() {
    super.initState();
    generateConnectedSchedule();
  }

  void generateConnectedSchedule() {
    final days = widget.endDate.difference(widget.startDate).inDays + 1;
    final targetDays = min(days, 15);
    scheduleData.clear();

    List<String> regionKeys = regionMap.keys.toList();
    String currentRegion = regionKeys[random.nextInt(regionKeys.length)];

    for (int day = 1; day <= targetDays; day++) {
      List<String> places = regionMap[currentRegion]!
          .where((p) => widget.tags.any((tag) => placeTags[p]?.contains(tag) ?? false))
          .toList();

      if (places.length < 5) {
        places = List.from(regionMap[currentRegion]!); // fallback
      }

      places.shuffle(random);

      final daySchedule = [
        {'time': '08:00', 'desc': '${places[0]} 출발'},
        {'time': '10:00', 'desc': '관광: ${places[1 % places.length]}'},
        {'time': '12:00', 'desc': '점심: ${places[2 % places.length]} 근처 맛집'},
        {'time': '14:00', 'desc': '관광: ${places[3 % places.length]}'},
        {'time': '17:00', 'desc': '산책 또는 카페: ${places[4 % places.length]}'},
        {'time': '19:00', 'desc': '숙소 체크인: ${places[5 % places.length]} 근처 숙소'},
      ];

      scheduleData[day] = daySchedule;

      List<String> neighbors = neighborRegions[currentRegion] ?? regionKeys;
      currentRegion = neighbors[random.nextInt(neighbors.length)];
    }
  }

  void _deleteItem(int day, int index) {
    setState(() {
      scheduleData[day]!.removeAt(index);
      selectedDay = null;
      selectedIndex = null;
    });
  }

  void _showInfoDialog(String desc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('정보'),
        content: Text(desc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
        ],
      ),
    );
  }

  void _showEditDialog(int day, int index) {
    final item = scheduleData[day]![index];
    final timeController = TextEditingController(text: item['time']);
    final descController = TextEditingController(text: item['desc']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('일정 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: '시간 (예: 08:00)'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: '일정 설명'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                scheduleData[day]![index] = {
                  'time': timeController.text.trim(),
                  'desc': descController.text.trim(),
                };
                selectedDay = null;
                selectedIndex = null;
              });
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
              centerTitle: true,
              title: const Text('여행 일정 리스트', style: TextStyle(color: Colors.black)),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• 여행 기간: ${widget.startDate.year}/${widget.startDate.month}/${widget.startDate.day} ~ ${widget.endDate.year}/${widget.endDate.month}/${widget.endDate.day}',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (widget.tags.isNotEmpty)
                  Text('• 유형: ${widget.tags.join(', ')}', style: const TextStyle(color: Colors.grey)),
                Text('• 인원: ${widget.people}명', style: const TextStyle(color: Colors.grey)),
                if (widget.relations.isNotEmpty)
                  Text('• 관계: ${widget.relations.join(', ')}', style: const TextStyle(color: Colors.grey)),
                if (widget.request.trim().isNotEmpty)
                  Text('• 요청사항: ${widget.request}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                for (int day in scheduleData.keys) ...[
                  Text('$day일차', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < scheduleData[day]!.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedDay == day && selectedIndex == i) {
                            selectedDay = null;
                            selectedIndex = null;
                          } else {
                            selectedDay = day;
                            selectedIndex = i;
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.circle, size: 8, color: Colors.grey),
                                if (i != scheduleData[day]!.length - 1)
                                  Container(width: 2, height: 32, color: Colors.grey.shade400),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(scheduleData[day]![i]['time']!, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(scheduleData[day]![i]['desc']!, style: const TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selectedDay == day && selectedIndex == i)
                      Padding(
                        padding: const EdgeInsets.only(left: 28, bottom: 12),
                        child: Row(
                          children: [
                            _actionButton('정보', Colors.grey, () => _showInfoDialog(scheduleData[day]![i]['desc']!)),
                            const SizedBox(width: 8),
                            _actionButton('수정', Colors.blue, () => _showEditDialog(day, i)),
                            const SizedBox(width: 8),
                            _actionButton('삭제', Colors.red, () => _deleteItem(day, i)),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.indigoAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: '일정'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '정보'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '안내'),
        ],
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: const Size(0, 32),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
