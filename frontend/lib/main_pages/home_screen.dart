import 'package:cookduck/mypages/bookmark.dart';
import 'package:cookduck/mypages/cook_story.dart';
import 'package:flutter/material.dart';
import 'package:cookduck/cooking/search_screen.dart';
import 'package:cookduck/screens/search_screen.dart' as db_search;
import 'package:cookduck/main_pages/take_picture_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookduck/config/api_config.dart';

class MyhomeScreen extends StatefulWidget {
  const MyhomeScreen({super.key});

  @override
  State<MyhomeScreen> createState() => _MyhomeScreenState();
}

class _MyhomeScreenState extends State<MyhomeScreen> {
  bool _isBookmarked = false;
  String? userGrade;

  @override
  void initState() {
    super.initState();
    _checkLogin();
    _printUserInfo();
    _fetchUserGrade();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _printUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final userName = prefs.getString('userName');
    final token = prefs.getString('jwt_token');
    print('홈화면 진입: user_id: ' + (userId ?? 'null'));
    print('홈화면 진입: userName: ' + (userName ?? 'null'));
    print('홈화면 진입: jwt_token: ' + (token ?? 'null'));
  }

  Future<void> _fetchUserGrade() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    print('등급 조회용 userId: $userId');
    if (userId == null || userId.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.springApiBase}/user-grade/$userId'),
      );
      print('등급 API 응답: \\${response.statusCode}, body: \\${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final grade = data['userGrade'] ?? '';
        setState(() {
          userGrade = grade;
        });
        print('userGrade 값: [' + grade + ']');
      } else {
        setState(() {
          userGrade = '등급 정보 없음';
        });
      }
    } catch (e) {
      setState(() {
        userGrade = '에러';
      });
    }
  }

  void _onCategoryTapped(String category) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('선택된 카테고리: $category')));
  }

  Widget _buildCategoryItem(
    String label,
    String icon, [
    Color? backgroundColor,
  ]) {
    return InkWell(
      onTap: () => _onCategoryTapped(label),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  String _getGradeImage(String? grade) {
    final g = grade?.trim();
    print('userGrade 값: [[33m[1m' + (g ?? 'null') + '\u001b[0m]');
    switch (g) {
      case '초보':
      case 'newbie':
        return 'assets/newbie.png';
      case '중급':
      case 'intermediate':
        return 'assets/intermediate.png';
      case '고급':
      case 'high':
        return 'assets/high.png';
      case '마스터':
      case 'master':
        return 'assets/master.png';
      default:
        return ''; // 기본 이미지 없음, null 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFE8EB87),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 검색 바
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => db_search.DatabaseSearchScreen()),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black, size: 26.0),
                    SizedBox(width: 16),
                    Text(
                      '검색',
                      style: TextStyle(fontSize: 17, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            // 카테고리
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCategoryItem('전체', 'ALL', Colors.orange),
                        _buildCategoryItem('국/탕', '🍲'),
                        _buildCategoryItem('찌개', '🍲'),
                        _buildCategoryItem('메인반찬', '🍳'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCategoryItem('밑반찬', '🥗'),
                        _buildCategoryItem('양식', '🍝'),
                        _buildCategoryItem('디저트', '🍪'),
                        _buildCategoryItem('차/음료/술', '🍺'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 프로필, CookStory, 북마크
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage:
                                  userGrade != null &&
                                          _getGradeImage(userGrade).isNotEmpty
                                      ? AssetImage(_getGradeImage(userGrade))
                                      : null,
                              child:
                                  userGrade == null ||
                                          _getGradeImage(userGrade).isEmpty
                                      ? Icon(Icons.person, size: 32)
                                      : null,
                            ),
                            SizedBox(height: 16),
                            Text(
                              userGrade ?? '등급',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _infoTile(Icons.book, 'MyDuck\nCookStory', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CookStory(),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        _infoTile(Icons.bookmark, '북마크', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Bookmark()),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // AI 기능 섹션
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🤖 AI 요리 도우미',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAIFeatureCard(
                          '🍳 레시피 추천',
                          '재료로 맞춤 레시피 찾기',
                          Colors.orange,
                          () => Navigator.pushNamed(context, '/recipe-recommendation'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildAIFeatureCard(
                          '👨‍🍳 요리 가이드',
                          '단계별 조리 도우미',
                          Colors.green,
                          () => Navigator.pushNamed(context, '/recipe-recommendation'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAIFeatureCard(
                          '💬 AI 챗봇',
                          '음성 대화형 요리 도우미',
                          Colors.purple,
                          () => Navigator.pushNamed(context, '/chat'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildAIFeatureCard(
                          '📸 재료 인식',
                          '사진으로 재료 분석',
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TakePictureScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 추천 레시피 섹션
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔥 오늘의 추천 레시피',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRecommendationCard(
                          '🍳 AI 추천',
                          '재료로 맞춤 레시피 찾기',
                          Colors.orange,
                          () => Navigator.pushNamed(context, '/recipe-recommendation'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildRecommendationCard(
                          '🔍 직접 검색',
                          'MariaDB에서 레시피 검색',
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => db_search.DatabaseSearchScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeatureCard(String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
