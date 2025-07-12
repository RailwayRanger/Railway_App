// travel_form_screen.dart
import 'package:flutter/material.dart';
import 'schedule_screen.dart';

class TravelFormScreen extends StatelessWidget {
  const TravelFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("여행 폼")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 예시로 일정 결과 화면으로 넘어가기
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TravelScheduleScreen(
                  scheduleData: {},
                  startDate: null,
                  endDate: null,
                  tags: [],
                  people: 0,
                  relations: [],
                  request: '',
                ),
              ),
            );
          },
          child: const Text('AI 일정 생성 후 결과 보기'),
        ),
      ),
    );
  }
}
