import 'package:flutter/material.dart';
import 'two.dart';

class TravelFormScreen extends StatefulWidget {
  const TravelFormScreen({super.key});

  @override
  State<TravelFormScreen> createState() => _TravelFormScreenState();
}

class _TravelFormScreenState extends State<TravelFormScreen> {
  DateTime startDate = DateTime(2025, 5, 23);
  DateTime endDate = DateTime(2025, 5, 25);
  final List<String> allTags = ['힐링', '액티비티', '문화/역사', '자연', '맛집', '감성', '도시'];
  final List<String> selectedTags = [];

  Map<String, int> peopleCounts = {
    '유아': 0,
    '청소년': 0,
    '청년': 0,
    '중장년': 0,
    '노인': 0,
  };

  final List<String> allRelations = ['혼자', '아이와 함께', '부모님과', '커플', '친구', '가족'];
  final List<String> selectedRelations = [];

  final TextEditingController requestController = TextEditingController();

  Future<void> pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  int get totalPeople => peopleCounts.values.reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
              title: Row(
                children: const [
                  Icon(Icons.arrow_back, color: Colors.black),
                  Spacer(),
                  Text('여행 일정 생성', style: TextStyle(color: Colors.black)),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Ai의 사용자 맞춤형 일정 생성',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('여행 기간 *'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _dateBox(startDate, () => pickDate(isStart: true))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('~'),
                          ),
                          Expanded(child: _dateBox(endDate, () => pickDate(isStart: false))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('여행 유형'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allTags.map((tag) => _tag(tag, selectedTags.contains(tag), () {
                          setState(() {
                            selectedTags.contains(tag)
                                ? selectedTags.remove(tag)
                                : selectedTags.add(tag);
                          });
                        })).toList(),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('여행 구성원 *'),
                      const SizedBox(height: 8),
                      ...peopleCounts.keys.map((label) => _counterRow(label)),
                      const SizedBox(height: 10),
                      Text(
                        '총: $totalPeople명   ' +
                            peopleCounts.entries.where((e) => e.value > 0).map((e) => '${e.key} ${e.value}명').join('   '),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('구성원 관계'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allRelations.map((relation) => _tag(relation, selectedRelations.contains(relation), () {
                          setState(() {
                            selectedRelations.contains(relation)
                                ? selectedRelations.remove(relation)
                                : selectedRelations.add(relation);
                          });
                        })).toList(),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('요청사항'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: requestController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: '부모님이랑 조용히 쉬고 싶어요 / 아이가 놀이공원 좋아해요',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );
                            Future.delayed(const Duration(seconds: 3), () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TravelScheduleScreen(
                                    startDate: startDate,
                                    endDate: endDate,
                                    tags: selectedTags,
                                    people: totalPeople,
                                    relations: selectedRelations,
                                    request: requestController.text,
                                  ),
                                ),
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Ai 여행 일정 생성', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, //
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
        onTap: null,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
  }

  Widget _dateBox(DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('${date.year}/${date.month}/${date.day}', style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _tag(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.indigoAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _counterRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  setState(() {
                    if (peopleCounts[label]! > 0) {
                      peopleCounts[label] = peopleCounts[label]! - 1;
                    }
                  });
                },
                iconSize: 20,
              ),
              Text('${peopleCounts[label]}', style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    peopleCounts[label] = peopleCounts[label]! + 1;
                  });
                },
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
