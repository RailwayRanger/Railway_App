// search.dart (변경 없음, 이전에 수정된 상태 유지)
import 'package:flutter/material.dart';
// TravelFormScreen이 ListOne.dart에 있다면 이 import는 필요 없습니다.
// import 'ListOne.dart'; // 이 줄은 제거하는 것이 좋습니다.

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    // SearchScreen은 Scaffold를 포함하지 않고, Body 내용만 반환합니다.
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: '여행지 관련 정보를 검색하세요.',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 버튼 2개
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                  child: const Text('웹 검색'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                  child: const Text('블로그 글'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 정보 제목
          const Text(
            '부산역 관련 정보',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://cdn.visitkorea.or.kr/img/call?cmd=VIEW&id=29082296-4e6b-4f68-988b-01d690a42ee6',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          // 텍스트 정보
          const Text('주소: 부산광역시 동구 중앙대로 206'),
          const Text('운영: 한국철도공사(Korail)'),
          const Text('개업일: 1908년 1월 1일'),
          const Text(
            '출구 정보: 총 9개의 출구가 있으며, 1~8번 출구는 부산역 광장으로, 9번 출구는 부산항 방향으로 연결됩니다.',
          ),
          const Text('열차 운행 정보: 5/23 8:00 동해선 출발'),
          const Text(
            '근처 관광명소: 부평깡통시장, 부산타워, 감천문화마을, 부산근현대 역사관',
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}