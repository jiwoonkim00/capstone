import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cookduck/config/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.fastApiBase;
  
  // RAG 레시피 추천 API
  static Future<Map<String, dynamic>> getRecipeRecommendations(List<String> ingredients) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recommend/rag?ingredients=${ingredients.join(',')}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recommendations: $e');
    }
  }
  
  // 요리 세션 시작
  static Future<Map<String, dynamic>> startCookingSession(String userId, int recipeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cook/select'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'recipe_id': recipeId,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to start cooking session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting cooking session: $e');
    }
  }
  
  // 제약사항 추가
  static Future<Map<String, dynamic>> addConstraint(String userId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cook/constraint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'message': message,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add constraint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding constraint: $e');
    }
  }
  
  // 다음 조리 단계
  static Future<Map<String, dynamic>> getNextStep(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cook/next'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get next step: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting next step: $e');
    }
  }
  
  // 현재 조리 단계
  static Future<Map<String, dynamic>> getCurrentStep(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/fastapi/cook/current?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get current step: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting current step: $e');
    }
  }
  
  // 세션 삭제
  static Future<Map<String, dynamic>> deleteSession(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cook/session/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting session: $e');
    }
  }
}