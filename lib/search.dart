import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];
  String _errorMessage = '';

  // 검색 타입: blog(블로그), webkr(웹문서)
  String searchType = 'blog';

  Future<void> _searchNaver(String keyword) async {
    const clientId = '4tUCG9RWDppH37qSWIvP';      // 네이버 Client ID
    const clientSecret = 'idUVln4JHc';              // 네이버 Client Secret

    final encodedKeyword = Uri.encodeQueryComponent(keyword);
    final url = Uri.parse(
        'https://openapi.naver.com/v1/search/$searchType.json?query=$encodedKeyword&display=10');

    try {
      final response = await http.get(url, headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _results = jsonData['items'];
          _errorMessage = '';
        });
      } else {
        setState(() {
          _results = [];
          _errorMessage = '검색 실패 (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _results = [];
        _errorMessage = '네트워크 오류';
      });
    }
  }

  void _onSearchSubmitted(String keyword) {
    if (keyword.trim().isEmpty) return;
    _searchNaver(keyword.trim());
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다.')),
      );
    }
  }

  Widget _buildSearchButton(String label, String type) {
    final bool selected = (searchType == type);
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          if (searchType != type) {
            setState(() {
              searchType = type;
            });
            final keyword = _searchController.text.trim();
            if (keyword.isNotEmpty) {
              _searchNaver(keyword);
            }
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? Colors.white : Colors.blue,
          backgroundColor: selected ? Colors.blue : Colors.white,
          side: BorderSide(color: Colors.blue),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 검색창
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: _searchController,
            onSubmitted: _onSearchSubmitted,
            decoration: const InputDecoration(
              hintText: '여행지 관련 정보를 검색하세요.',
              border: InputBorder.none,
              icon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 버튼 2개 (웹 검색 / 블로그 글)
        Row(children: [
          _buildSearchButton('웹 검색', 'webkr'),
          const SizedBox(width: 10),
          _buildSearchButton('블로그 글', 'blog'),
        ]),
        const SizedBox(height: 20),
        // 결과 출력
        if (_results.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _results.map((item) {
              final title =
              item['title'].toString().replaceAll(RegExp(r'<.*?>'), '');
              final description =
              item['description'].toString().replaceAll(RegExp(r'<.*?>'), '');
              final link = item['link'];

              return InkWell(
                onTap: () => _launchURL(link),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(description),
                      const SizedBox(height: 4),
                      Text('URL: $link',
                          style:
                          const TextStyle(color: Colors.blue, fontSize: 12)),
                      const Divider(),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        else if (_errorMessage.isNotEmpty)
          Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 30),
      ]),
    );
  }
}