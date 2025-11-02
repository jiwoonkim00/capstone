import 'package:flutter/material.dart';
import '../services/search_service.dart';

class DatabaseSearchScreen extends StatefulWidget {
  @override
  _DatabaseSearchScreenState createState() => _DatabaseSearchScreenState();
}

class _DatabaseSearchScreenState extends State<DatabaseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔍 레시피 검색'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 검색 입력
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '레시피명, 재료, 카테고리로 검색하세요',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _performSearch(),
                      onChanged: (value) => setState(() {}),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _performSearch,
                            icon: _isLoading 
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(Icons.search),
                            label: Text(_isLoading ? '검색 중...' : '검색'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _loadPopularRecipes,
                          icon: Icon(Icons.trending_up),
                          label: Text('인기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _loadRecentRecipes,
                          icon: Icon(Icons.schedule),
                          label: Text('최신'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // 에러 메시지
            if (_errorMessage.isNotEmpty)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // 검색 결과
            Expanded(
              child: _searchResults.isEmpty && !_isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            '레시피를 검색해보세요!',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '레시피명, 재료, 카테고리로 검색할 수 있습니다.',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final recipe = _searchResults[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              recipe['title'] ?? '제목 없음',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (recipe['ingredients'] != null)
                                  Text(
                                    '재료: ${recipe['ingredients']}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                if (recipe['category'] != null)
                                  Text(
                                    '카테고리: ${recipe['category']}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                if (recipe['cookingTime'] != null)
                                  Text(
                                    '조리시간: ${recipe['cookingTime']}분',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () => _showRecipeDetail(recipe),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _currentSearchQuery = query;
    });

    try {
      final results = await SearchService.searchRecipes(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '검색 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPopularRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _currentSearchQuery = '인기 레시피';
    });

    try {
      final results = await SearchService.getPopularRecipes();
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '인기 레시피를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _currentSearchQuery = '최신 레시피';
    });

    try {
      final results = await SearchService.getRecentRecipes();
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '최신 레시피를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _showRecipeDetail(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe['title'] ?? '레시피 상세'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (recipe['ingredients'] != null) ...[
                Text('재료:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(recipe['ingredients']),
                SizedBox(height: 16),
              ],
              if (recipe['content'] != null) ...[
                Text('조리법:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(recipe['content']),
                SizedBox(height: 16),
              ],
              if (recipe['category'] != null)
                Text('카테고리: ${recipe['category']}'),
              if (recipe['cookingTime'] != null)
                Text('조리시간: ${recipe['cookingTime']}분'),
              if (recipe['servings'] != null)
                Text('인분: ${recipe['servings']}인분'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 레시피 선택 시 요리 세션으로 이동
              Navigator.pushNamed(
                context,
                '/cooking-session',
                arguments: {
                  'recipe': recipe,
                  'ingredients': (recipe['ingredients'] ?? '').split(','),
                },
              );
            },
            child: Text('요리 시작'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
