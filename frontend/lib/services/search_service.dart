import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cookduck/config/api_config.dart';

class SearchService {
  static const String baseUrl = ApiConfig.springApiBase;
  
  // 키워드로 레시피 검색
  static Future<List<Map<String, dynamic>>> searchRecipes(
    String keyword, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/search/recipes?keyword=${Uri.encodeComponent(keyword)}&page=$page&size=$size'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> recipes = json.decode(response.body);
        return recipes.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching recipes: $e');
    }
  }
  
  // 재료로 레시피 검색
  static Future<List<Map<String, dynamic>>> searchRecipesByIngredients(
    List<String> ingredients, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final ingredientsParam = ingredients.map((ing) => Uri.encodeComponent(ing)).join(',');
      final response = await http.get(
        Uri.parse('$baseUrl/api/search/recipes/by-ingredients?ingredients=$ingredientsParam&page=$page&size=$size'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> recipes = json.decode(response.body);
        return recipes.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search recipes by ingredients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching recipes by ingredients: $e');
    }
  }
  
  // 카테고리로 레시피 검색
  static Future<List<Map<String, dynamic>>> searchRecipesByCategory(
    String category, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/search/recipes/by-category?category=${Uri.encodeComponent(category)}&page=$page&size=$size'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> recipes = json.decode(response.body);
        return recipes.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search recipes by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching recipes by category: $e');
    }
  }
  
  // 레시피 상세 정보
  static Future<Map<String, dynamic>> getRecipeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/search/recipes/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get recipe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recipe: $e');
    }
  }
  
  // 인기 레시피
  static Future<List<Map<String, dynamic>>> getPopularRecipes({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/search/recipes/popular?page=$page&size=$size'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> recipes = json.decode(response.body);
        return recipes.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get popular recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting popular recipes: $e');
    }
  }
  
  // 최신 레시피
  static Future<List<Map<String, dynamic>>> getRecentRecipes({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/search/recipes/recent?page=$page&size=$size'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> recipes = json.decode(response.body);
        return recipes.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get recent recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recent recipes: $e');
    }
  }
}
