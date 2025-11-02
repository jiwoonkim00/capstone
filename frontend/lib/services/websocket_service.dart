import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:cookduck/config/api_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final StreamController<dynamic> _streamController =
      StreamController.broadcast();

  Stream<dynamic> get stream => _streamController.stream;

  // FastAPI WebSocket (음성 채팅)
  final String _serverUrl = '${ApiConfig.wsBaseUrl}/api/fastapi/ws/chat';

  void connect() {
    if (_channel != null && _channel!.closeCode == null) {
      print('✅ 이미 WebSocket에 연결되어 있습니다.');
      return;
    }
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      print('✅ WebSocket 서버에 연결합니다: $_serverUrl');
      // 모든 메시지를 그대로 스트림으로 전달
      _channel!.stream.listen(
        (message) => _streamController.add(message),
        onDone: () => print('🔌 WebSocket 연결 종료.'),
        onError: (error) => print('❌ WebSocket 에러: $error'),
      );
    } catch (e) {
      print('❌ WebSocket 연결 실패: $e');
    }
  }

  Future<void> sendAudioFile(String filePath) async {
    if (_channel == null || _channel!.closeCode != null) {
      print('⚠️ WebSocket이 연결되지 않았습니다.');
      return;
    }
    final file = File(filePath);
    _channel!.sink.add(await file.readAsBytes());
    print('🔊 녹음된 오디오 파일을 서버로 전송합니다...');
  }

  void dispose() {
    _streamController.close();
    _channel?.sink.close();
    _channel = null;
  }
}
