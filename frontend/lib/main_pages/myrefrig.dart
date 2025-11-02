import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookduck/config/api_config.dart';

class Myrefrig extends StatefulWidget {
  const Myrefrig({super.key});

  @override
  State<Myrefrig> createState() => _MyrefrigState();
}

class _MyrefrigState extends State<Myrefrig> {
  List<String> seasonings = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchSeasonings();
  }

  Future<void> _fetchSeasonings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      print('[조미료] SharedPreferences user_id: ' + (userId ?? 'null'));
      if (userId == null || userId.isEmpty) {
        setState(() {
          errorMsg = '로그인 정보가 없습니다.';
          isLoading = false;
        });
        print('[조미료] user_id 없음, 로그인 필요');
        return;
      }
      final url = '${ApiConfig.springApiBase}/user-seasonings/$userId';
      print('[조미료] GET $url');
      final response = await http.get(Uri.parse(url));
      print('[조미료] 응답 status: ${response.statusCode}');
      print('[조미료] 응답 body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[조미료] 파싱된 데이터: $data');
        final List<String> result = [];
        if (data is Map<String, dynamic>) {
          data.forEach((key, value) {
            if (value == true) {
              result.add(key);
            }
          });
        }
        setState(() {
          seasonings = result;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = '서버 오류: ${response.statusCode}';
          isLoading = false;
        });
        print('[조미료] 서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMsg = '에러: $e';
        isLoading = false;
      });
      print('[조미료] 예외 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EB87),
      appBar: AppBar(
        backgroundColor: Color(0xFFE8EB87),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('냉장고'),
            Image(image: AssetImage('assets/logo.png'), width: 40),
          ],
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      body: Container(
        width: 340,
        height: 500,
        margin: EdgeInsets.all(40),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(175),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '조미료',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child:
                  isLoading
                      ? const Text('불러오는 중...')
                      : errorMsg != null
                      ? Text(
                        errorMsg!,
                        style: const TextStyle(color: Colors.red),
                      )
                      : Text(
                        seasonings.isNotEmpty
                            ? seasonings.join(', ')
                            : '조미료 정보 없음',
                      ),
            ),
            const SizedBox(height: 24),
            const Text(
              '식재료',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: const Text('양파, 마늘, 상추, 돼지고기'), // 예시 데이터
            ),
          ],
        ),
      ),
    );
  }
}
