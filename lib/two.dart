import 'dart:convert';
// import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart'; // MainScreen의 GlobalKey에 접근
import 'package:http/http.dart' as http;
// import 'dart:concurrent';

class TravelScheduleScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<String> tags;
  final int people;
  final List<String> relations;
  final String request;
  final Map<int, List<Map<String, String>>> scheduleData;

  const TravelScheduleScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.tags,
    required this.people,
    required this.relations,
    required this.request,
    required this.scheduleData,
  });

  @override
  State<TravelScheduleScreen> createState() => _TravelScheduleScreenState();
}

class _TravelScheduleScreenState extends State<TravelScheduleScreen> {
  int? selectedDay;
  int? selectedIndex;

  void _deleteItem(int day, int index) {
    setState(() {
      widget.scheduleData[day]!.removeAt(index);
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
    final item = widget.scheduleData[day]![index];
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.scheduleData[day]![index] = {
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
                const SizedBox(height: 16),


                for (int day in widget.scheduleData.keys) ...[
                  Text('$day일차', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < widget.scheduleData[day]!.length; i++) ...[
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
                                if (i != widget.scheduleData[day]!.length - 1)
                                  Container(width: 2, height: 32, color: Colors.grey.shade400),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(widget.scheduleData[day]![i]['time']!, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(widget.scheduleData[day]![i]['desc']!, style: const TextStyle(fontSize: 14)),
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
                            _actionButton('정보', Colors.grey, () => _showInfoDialog(widget.scheduleData[day]![i]['desc']!)),
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
                // 👇 반복문 다 끝난 후 추가
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.white,),
                      label: const Text('리스트 삭제', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        MainScreen.globalKey.currentState?.setTab(0);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save, size: 18, color: Colors.white),
                      label: const Text('리스트 저장', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
                      onPressed: () async {
                        final convertedScheduleData = widget.scheduleData.map(
                              (k, v) => MapEntry(
                            k.toString(),
                            v.map((item) => {
                              'time': item['time'] ?? '',
                              'desc': item['desc'] ?? '',
                            }).toList(),
                          ),
                        );

                        final bodyData = {
                          'startDate': widget.startDate.toIso8601String(),
                          'endDate': widget.endDate.toIso8601String(),
                          'tags': widget.tags,
                          'people': widget.people,
                          'relations': widget.relations,
                          'request': widget.request,
                          'scheduleData': convertedScheduleData,
                        };

                        final response = await http.post(
                          Uri.parse('https://port-0-railway-backend-mczsqk1b8f7c8972.sel5.cloudtype.app/schedule'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(bodyData),
                        );
                        print('응답 상태코드: ${response.statusCode}');
                        print('응답 본문: ${response.body}');


                        if (response.statusCode == 200 || response.statusCode == 201) {
                          if (context.mounted) {
                            Navigator.popUntil(context, (route) => route.isFirst);
                            MainScreen.globalKey.currentState?.setTab(0);

                            ScaffoldMessenger.of(MainScreen.globalKey.currentContext!).showSnackBar(
                              const SnackBar(content: Text('✅ 일정이 저장되었습니다.')),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('오류'),
                                content: const Text('일정 저장에 실패했습니다.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
                                ],
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

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
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: '일정'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '정보'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: '안내'),
        ],
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          Navigator.popUntil(context, (route) => route.isFirst);
          MainScreen.globalKey.currentState?.setTab(index);
        },
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