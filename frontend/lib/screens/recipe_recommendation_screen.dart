import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecipeRecommendationScreen extends StatefulWidget {
  @override
  _RecipeRecommendationScreenState createState() => _RecipeRecommendationScreenState();
}

class _RecipeRecommendationScreenState extends State<RecipeRecommendationScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  List<String> _ingredients = [];
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🍳 레시피 추천'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 재료 입력 섹션
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '재료를 입력하세요',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ingredientController,
                            decoration: InputDecoration(
                              hintText: '예: 김치, 계란, 고추장',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addIngredient(),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addIngredient,
                          child: Text('추가'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // 선택된 재료 표시
                    if (_ingredients.isNotEmpty) ...[
                      Text('선택된 재료:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _ingredients.map((ingredient) => Chip(
                          label: Text(ingredient),
                          deleteIcon: Icon(Icons.close, size: 18),
                          onDeleted: () => _removeIngredient(ingredient),
                        )).toList(),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _ingredients.isNotEmpty ? _getRecommendations : null,
                          icon: _isLoading ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ) : Icon(Icons.search),
                          label: Text(_isLoading ? '검색 중...' : '레시피 추천받기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
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
                      Expanded(child: Text(_errorMessage, style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            
            // 추천 결과
            if (_recommendations.isNotEmpty) ...[
              Text(
                '추천 레시피 (${_recommendations.length}개)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final recipe = _recommendations[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          recipe['title'] ?? '제목 없음',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recipe['description'] != null)
                              Text(recipe['description']),
                            if (recipe['ingredients'] != null)
                              Text('재료: ${recipe['ingredients'].join(', ')}'),
                            if (recipe['tips'] != null)
                              Text('💡 ${recipe['tips']}'),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => _selectRecipe(recipe),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty && !_ingredients.contains(ingredient)) {
      setState(() {
        _ingredients.add(ingredient);
        _ingredientController.clear();
        _errorMessage = '';
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  Future<void> _getRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ApiService.getRecipeRecommendations(_ingredients);
      
      setState(() {
        _recommendations = List<Map<String, dynamic>>.from(result['recommendations'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '추천을 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _selectRecipe(Map<String, dynamic> recipe) {
    // 레시피 선택 시 요리 세션으로 이동
    Navigator.pushNamed(
      context,
      '/cooking-session',
      arguments: {
        'recipe': recipe,
        'ingredients': _ingredients,
      },
    );
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }
}
