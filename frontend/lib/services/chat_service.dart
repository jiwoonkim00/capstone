import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:cookduck/config/api_config.dart';

class ChatService {
  static const String baseUrl = ApiConfig.wsBaseUrl;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  
  // WebSocket 연결
  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('$baseUrl/api/fastapi/ws/chat'));
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
      
      _channel!.stream.listen(
        (data) {
          try {
            final message = json.decode(data);
            _messageController!.add(message);
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }
  
  // 메시지 전송
  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode({
        'type': 'message',
        'content': message,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    }
  }
  
  // 음성 메시지 전송
  void sendVoiceMessage(List<int> audioData) {
    if (_channel != null) {
      _channel!.sink.add(json.encode({
        'type': 'voice',
        'audio_data': base64Encode(audioData),
        'timestamp': DateTime.now().toIso8601String(),
      }));
    }
  }
  
  // 메시지 스트림 구독
  Stream<Map<String, dynamic>> get messageStream {
    if (_messageController == null) {
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _messageController!.stream;
  }
  
  // 연결 해제
  void disconnect() {
    _channel?.sink.close();
    _messageController?.close();
    _channel = null;
    _messageController = null;
  }
}
