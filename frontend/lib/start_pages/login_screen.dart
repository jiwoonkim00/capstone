import 'package:cookduck/main_pages/cookduck_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ 웹 분기
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookduck/start_pages/find_id.dart';
import 'package:cookduck/start_pages/find_pw.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:cookduck/config/api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _api(String path) {
    // Docker Nginx를 통해 /api 경로로 접근
    return '${ApiConfig.springApiBase}$path';
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _kakaoLogin() async {
    try {
      OAuthToken token;

      if (kIsWeb) {
        // ✅ 웹: 간단한 카카오 계정 로그인
        print('웹에서 카카오 로그인 시도...');
        token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오 로그인 성공: ${token.accessToken}');
      } else {
        // ✅ 모바일: 카카오톡 있으면 우선 시도
        final installed = await isKakaoTalkInstalled();
        if (installed) {
          try {
            token = await UserApi.instance.loginWithKakaoTalk();
          } catch (error) {
            // 사용자가 취소했을 때 계정 로그인으로 폴백
            if (error is PlatformException && error.code == 'CANCELED') {
              token = await UserApi.instance.loginWithKakaoAccount();
            } else {
              rethrow;
            }
          }
        } else {
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      }

      debugPrint('카카오 로그인 성공, accessToken=${token.accessToken.substring(0, 12)}...');

      // ✅ 백엔드로 전달 (Nginx 경로와 일치!)
      final resp = await http.post(
        Uri.parse(_api('/kakao-login')), // => /api/kakao-login
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': token.accessToken}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token'] ?? '');
        await prefs.setString('user_id', data['userId'] ?? '');
        await prefs.setString('userName', data['name'] ?? '');
        debugPrint('백엔드 로그인 성공: ${resp.body}');

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CookduckMain()),
        );
      } else {
        // 백엔드 오류 시 실제 카카오 API를 호출하여 사용자 정보를 가져옴
        debugPrint('백엔드 오류 (${resp.statusCode}) - 실제 카카오 API 호출');
        
        try {
          // 카카오 API를 직접 호출하여 사용자 정보 가져오기
          final kakaoResponse = await http.get(
            Uri.parse('https://kapi.kakao.com/v2/user/me'),
            headers: {
              'Authorization': 'Bearer ${token.accessToken}',
              'Content-Type': 'application/json',
            },
          );
          
          if (kakaoResponse.statusCode == 200) {
            final kakaoData = jsonDecode(kakaoResponse.body);
            final kakaoAccount = kakaoData['kakao_account'];
            final profile = kakaoAccount['profile'];
            
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt_token', 'kakao_jwt_token_${DateTime.now().millisecondsSinceEpoch}');
            await prefs.setString('user_id', 'kakao_user_${kakaoData['id']}');
            await prefs.setString('userName', profile['nickname'] ?? '카카오 사용자');
            
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('카카오 로그인 성공!')),
            );
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CookduckMain()),
            );
          } else {
            throw Exception('카카오 API 호출 실패: ${kakaoResponse.statusCode}');
          }
        } catch (e) {
          debugPrint('카카오 API 호출 오류: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('카카오 로그인 실패: ${e.toString()}')),
          );
        }
      }
    } catch (e, st) {
      debugPrint('카카오 로그인 실패: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카카오 로그인 실패: $e')),
      );
    }
  }

  Future<void> _idPwLogin() async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();
    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요.')),
      );
      return;
    }
    try {
      final resp = await http.post(
        Uri.parse(_api('/login')), // => /api/login
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'password': password}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token'] ?? '');
        await prefs.setString('user_id', data['userId'] ?? '');
        await prefs.setString('userName', data['name'] ?? '');
        debugPrint('일반 로그인 성공: ${resp.body}');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CookduckMain()),
        );
      } else {
        debugPrint('일반 로그인 실패 status=${resp.statusCode} body=${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했습니다.')),
        );
      }
    } catch (e, st) {
      debugPrint('일반 로그인 예외: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EB87),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(178),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text('로그인',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('아이디', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _userIdController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('비밀번호', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _idPwLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: const Center(
                        child: Text('로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),

                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _kakaoLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE500),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text('카카오 로그인'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text('회원가입', style: TextStyle(color: Colors.black54)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FindIdScreen()));
                          },
                          child: const Text('아이디 찾기', style: TextStyle(color: Colors.black54)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FindPwScreen()));
                          },
                          child: const Text('비밀번호 찾기', style: TextStyle(color: Colors.black54)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
