import 'package:cookduck/main_pages/cookduck_main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'start_pages/splash_screen.dart';
import 'start_pages/login_screen.dart';
import 'start_pages/signup_screen.dart';
import 'screens/recipe_recommendation_screen.dart';
import 'screens/cooking_session_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/search_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

/// ✅ 카카오 앱 키 (Flutter SDK 전용)
const String _kakaoNativeAppKey   = '739d996038b1bb07614811ec4a17051e'; // Android/iOS
const String _kakaoJavaScriptKey  = '71e076297429be73a2685517ae69deec'; // Web
// ⚠️ REST API 키는 서버(Spring/FastAPI)에서만 사용 (앱에 절대 포함 금지)

/// ✅ 웹 로그인 Redirect URI
/// 카카오 개발자 콘솔에 반드시 "Redirect URI"로 등록해야 함
/// http://localhost:81/kakao/callback  또는 ngrok 도메인 포함
const String _webRedirectUri = 'http://localhost:81/kakao/callback';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Kakao SDK 초기화 (플랫폼별 자동 구분)
  KakaoSdk.init(
    nativeAppKey: _kakaoNativeAppKey,
    javaScriptAppKey: _kakaoJavaScriptKey,
  );

  // ✅ 한국어 날짜 포맷 초기화
  await initializeDateFormatting('ko_KR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cook Duck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE8EB87)),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // ✅ 첫 화면 (스플래시)
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const CookduckMain(),
        '/recipe-recommendation': (_) => RecipeRecommendationScreen(),
        '/cooking-session': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CookingSessionScreen(
            recipe: args['recipe'],
            ingredients: List<String>.from(args['ingredients']),
          );
        },
        '/chat': (_) => ChatScreen(),
        '/search': (_) => DatabaseSearchScreen(),
      },
    );
  }
}
