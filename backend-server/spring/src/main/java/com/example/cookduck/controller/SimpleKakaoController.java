package com.example.cookduck.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class SimpleKakaoController {

    @PostMapping("/kakao-login")
    public ResponseEntity<Map<String, Object>> kakaoLogin(@RequestBody Map<String, String> request) {
        System.out.println("=== 카카오 로그인 API 호출됨 ===");
        System.out.println("요청 데이터: " + request);
        
        String accessToken = request.get("accessToken");
        
        if (accessToken == null || accessToken.isEmpty()) {
            System.out.println("Access token이 없습니다.");
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Access token is required");
            return ResponseEntity.badRequest().body(errorResponse);
        }

        System.out.println("Access token: " + accessToken);

        // 임시로 더미 응답 반환
        Map<String, Object> response = new HashMap<>();
        response.put("token", "dummy_jwt_token_" + System.currentTimeMillis());
        response.put("userId", "kakao_user_" + accessToken.hashCode());
        response.put("name", "카카오 사용자");
        response.put("message", "카카오 로그인 성공");
        
        System.out.println("응답 데이터: " + response);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/test")
    public ResponseEntity<Map<String, Object>> test() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Spring Boot is working!");
        response.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(response);
    }
}


