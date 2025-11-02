import 'package:flutter/material.dart';
import 'package:cookduck/cooking/ready_cook.dart';
import 'package:cookduck/models/recipe.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Recipe> _searchResults = [];

  // API에서 레시피 데이터를 가져오는 함수
  List<Recipe> _searchRecipes(String query) {
    // 실제로는 API 호출을 통해 데이터를 가져와야 함
    // 현재는 빈 리스트 반환 (API 연동 필요)
    return [];
  }

  @override
  void initState() {
    super.initState();
    _searchResults = []; // 초기엔 빈 리스트
  }

  // 2. 실시간 검색 함수
  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _searchResults = []; // 빈 검색어면 빈 리스트
      } else {
        _searchResults = _searchRecipes(query); // API 호출로 검색
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EB87),
      appBar: AppBar(
        backgroundColor: Color(0xFFE8EB87),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(175),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '검색',
                    border: InputBorder.none,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  _controller.clear();
                  _onSearchChanged('');
                },
              ),
            ],
          ),
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('----- 추천 레시피 -----'),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Readycook()),
                );
              },
              child: const Text(
                'JMT 비빔국수',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _searchResults.isNotEmpty
                      ? ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, idx) {
                          final recipe = _searchResults[idx];
                          return ListTile(
                            leading:
                                recipe.imageUrl.isNotEmpty
                                    ? Image.network(
                                      recipe.imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.fastfood),
                            title: Text(recipe.title),
                            subtitle: Text(
                              recipe.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              // TODO: 상세 페이지로 이동 구현
                            },
                          );
                        },
                      )
                      : const Center(child: Text('검색 결과 없음')),
            ),
          ],
        ),
      ),
    );
  }
}
