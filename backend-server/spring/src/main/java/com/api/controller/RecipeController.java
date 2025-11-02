package com.api.controller;

import com.api.service.FastApiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class RecipeController {
    
    @Autowired
    private FastApiService fastApiService;
    
    /**
     * FAISS 기반 레시피 추천
     */
    @PostMapping("/recommend")
    public ResponseEntity<?> recommendRecipes(@RequestBody Map<String, Object> request) {
        @SuppressWarnings("unchecked")
        List<String> ingredients = (List<String>) request.get("ingredients");
        
        if (ingredients == null || ingredients.isEmpty()) {
            return ResponseEntity.badRequest().body(
                Map.of("error", "재료 목록이 비어있습니다.")
            );
        }
        
        return fastApiService.getRecommendations(ingredients);
    }
    
    /**
     * RAG 기반 레시피 추천
     */
    @PostMapping("/recommend/rag")
    public ResponseEntity<?> recommendRecipesWithRag(@RequestBody Map<String, Object> request) {
        @SuppressWarnings("unchecked")
        List<String> ingredients = (List<String>) request.get("ingredients");
        
        if (ingredients == null || ingredients.isEmpty()) {
            return ResponseEntity.badRequest().body(
                Map.of("error", "재료 목록이 비어있습니다.")
            );
        }
        
        return fastApiService.getRagRecommendations(ingredients);
    }
    
    /**
     * 시스템 상태 확인
     */
    @GetMapping("/system/status")
    public ResponseEntity<?> getSystemStatus() {
        return fastApiService.getSystemStatus();
    }
    
    /**
     * 성능 측정
     */
    @PostMapping("/recommend/performance")
    public ResponseEntity<?> measurePerformance(@RequestBody Map<String, Object> request) {
        @SuppressWarnings("unchecked")
        List<String> ingredients = (List<String>) request.get("ingredients");
        
        if (ingredients == null || ingredients.isEmpty()) {
            return ResponseEntity.badRequest().body(
                Map.of("error", "재료 목록이 비어있습니다.")
            );
        }
        
        return fastApiService.measurePerformance(ingredients);
    }
    
    /**
     * WebSocket URL 반환
     */
    @GetMapping("/chat/ws")
    public ResponseEntity<?> getChatWebSocket() {
        return fastApiService.getWebSocketUrl();
    }
    
    /**
     * 헬스 체크
     */
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "service", "Spring Boot + FastAPI Integration",
            "timestamp", System.currentTimeMillis()
        ));
    }
}
