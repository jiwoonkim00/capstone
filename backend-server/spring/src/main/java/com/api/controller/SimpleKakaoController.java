package com.api.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class SimpleKakaoController {

    @Value("${kakao.rest-key}")
    private String kakaoRestKey;

    private final RestTemplate restTemplate = new RestTemplate();

    @PostMapping("/kakao-login")
    public ResponseEntity<Map<String, Object>> kakaoLogin(@RequestBody Map<String, String> request) {
        try {
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

            // 카카오 API를 호출하여 사용자 정보를 가져오기
            String kakaoApiUrl = "https://kapi.kakao.com/v2/user/me";
            
            HttpHeaders headers = new HttpHeaders();
            headers.setBearerAuth(accessToken);
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            try {
                ResponseEntity<Map> response = restTemplate.exchange(
                    kakaoApiUrl, 
                    HttpMethod.GET, 
                    entity, 
                    Map.class
                );
                
                if (response.getStatusCode() == HttpStatus.OK) {
                    Map<String, Object> kakaoUserInfo = response.getBody();
                    System.out.println("카카오 사용자 정보: " + kakaoUserInfo);
                    
                    // 카카오 사용자 정보에서 필요한 데이터 추출
                    Map<String, Object> kakaoAccount = (Map<String, Object>) kakaoUserInfo.get("kakao_account");
                    Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");
                    
                    String nickname = (String) profile.get("nickname");
                    String email = (String) kakaoAccount.get("email");
                    Long kakaoId = (Long) kakaoUserInfo.get("id");
                    
                    // 실제 JWT 토큰 생성 (실제 구현 필요)
                    Map<String, Object> responseData = new HashMap<>();
                    responseData.put("token", "real_jwt_token_" + System.currentTimeMillis());
                    responseData.put("userId", "kakao_" + kakaoId);
                    responseData.put("name", nickname);
                    responseData.put("email", email);
                    responseData.put("kakaoId", kakaoId);
                    responseData.put("message", "카카오 로그인 성공");
                    
                    System.out.println("응답 데이터: " + responseData);
                    return ResponseEntity.ok(responseData);
                } else {
                    System.out.println("카카오 API 호출 실패: " + response.getStatusCode());
                    Map<String, Object> errorResponse = new HashMap<>();
                    errorResponse.put("error", "카카오 API 호출 실패: " + response.getStatusCode());
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
                }
            } catch (Exception e) {
                System.out.println("카카오 API 호출 중 오류: " + e.getMessage());
                e.printStackTrace();
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("error", "카카오 API 호출 중 오류: " + e.getMessage());
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
            }
            
        } catch (Exception e) {
            System.out.println("카카오 로그인 오류: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "카카오 로그인 처리 중 오류 발생: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
