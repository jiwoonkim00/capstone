import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../services/websocket_service.dart';
import 'dart:typed_data';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  String? _audioPath;
  Uint8List? _currentBotAudioBuffer;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _webSocketService.connect();

    _webSocketService.stream.listen((message) {
      if (!mounted) return;
      if (message is String) {
        final decoded = json.decode(message);
        final type = decoded['type'];
        setState(() {
          if (type == 'bot_text') {
            _messages.add('[AI] ${decoded['data']}');
            _currentBotAudioBuffer = Uint8List(0);
          } else if (type == 'chat_result') {
            _messages.add('[나] ${decoded['user_text']}');
            _messages.add('[AI] ${decoded['bot_text']}');
            _currentBotAudioBuffer = Uint8List(0);
          } else if (type == 'event' && decoded['data'] == 'TTS_STREAM_END') {
            if (_currentBotAudioBuffer != null &&
                _currentBotAudioBuffer!.isNotEmpty) {
              print('🎧 AI 음성 스트림 수신 완료. 재생을 시작합니다...');
              _audioPlayer.play(BytesSource(_currentBotAudioBuffer!));
              _currentBotAudioBuffer = null;
            }
          }
        });
      } else if (message is Uint8List) {
        if (_currentBotAudioBuffer != null) {
          _currentBotAudioBuffer = Uint8List.fromList([
            ..._currentBotAudioBuffer!,
            ...message,
          ]);
        }
      }
    });
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
      print('▶️ 녹음 중지. 파일 저장 경로: $_audioPath');
      if (_audioPath != null) {
        _webSocketService.sendAudioFile(_audioPath!);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: '${dir.path}/my_question.wav',
        );
        setState(() {
          _isRecording = true;
        });
        print('🎤 녹음 시작...');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('쿡덕 챗봇')),
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, idx) => ListTile(title: Text(_messages[idx])),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleRecording,
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}
