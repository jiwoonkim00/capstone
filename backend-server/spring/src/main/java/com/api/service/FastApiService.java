package com.api.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;

import java.util.*;

@Service
public class FastApiService {
    
    private final RestTemplate restTemplate;
    private final String FASTAPI_BASE_URL = "http://fastapi:8000";
    
    @Autowired
    public FastApiService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }
    
    /**
     * FAISS 기반 레시피 추천
     */
    public ResponseEntity<?> getRecommendations(List<String> ingredients) {
        try {
            String url = FASTAPI_BASE_URL + "/api/fastapi/recommend";
            
            Map<String, Object> request = new HashMap<>();
            request.put("ingredients", ingredients);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);
            
            ResponseEntity<?> response = restTemplate.postForEntity(url, entity, Object.class);
            return ResponseEntity.ok(response.getBody());
            
        } catch (HttpClientErrorException | HttpServerErrorException e) {
            return ResponseEntity.status(e.getStatusCode()).body(
                Map.of("error", "FastAPI 호출 실패: " + e.getMessage())
            );
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Map.of("error", "서버 오류: " + e.getMessage())
            );
        }
    }
    
    /**
     * RAG 기반 레시피 추천
     */
    public ResponseEntity<?> getRagRecommendations(List<String> ingredients) {
        try {
            String url = FASTAPI_BASE_URL + "/api/fastapi/recommend/rag";
            
            Map<String, Object> request = new HashMap<>();
            request.put("ingredients", ingredients);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);
            
            ResponseEntity<?> response = restTemplate.postForEntity(url, entity, Object.class);
            return ResponseEntity.ok(response.getBody());
            
        } catch (HttpClientErrorException | HttpServerErrorException e) {
            return ResponseEntity.status(e.getStatusCode()).body(
                Map.of("error", "FastAPI RAG 호출 실패: " + e.getMessage())
            );
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Map.of("error", "서버 오류: " + e.getMessage())
            );
        }
    }
    
    /**
     * 시스템 상태 확인
     */
    public ResponseEntity<?> getSystemStatus() {
        try {
            String url = FASTAPI_BASE_URL + "/api/fastapi/system/status";
            ResponseEntity<?> response = restTemplate.getForEntity(url, Object.class);
            return ResponseEntity.ok(response.getBody());
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Map.of("error", "시스템 상태 확인 실패: " + e.getMessage())
            );
        }
    }
    
    /**
     * 성능 측정
     */
    public ResponseEntity<?> measurePerformance(List<String> ingredients) {
        try {
            String url = FASTAPI_BASE_URL + "/api/fastapi/recommend/performance";
            
            Map<String, Object> request = new HashMap<>();
            request.put("ingredients", ingredients);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);
            
            ResponseEntity<?> response = restTemplate.postForEntity(url, entity, Object.class);
            return ResponseEntity.ok(response.getBody());
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Map.of("error", "성능 측정 실패: " + e.getMessage())
            );
        }
    }
    
    /**
     * WebSocket URL 반환
     */
    public ResponseEntity<?> getWebSocketUrl() {
        Map<String, Object> response = new HashMap<>();
        response.put("websocket_url", "ws://localhost:81/api/fastapi/ws/chat");
        response.put("description", "음성 채팅 WebSocket 연결 URL");
        return ResponseEntity.ok(response);
    }
}
