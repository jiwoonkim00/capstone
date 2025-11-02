import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  StreamController<String>? _speechController;
  
  // 음성 인식 초기화
  Future<bool> initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    return available;
  }
  
  // 음성 인식 시작
  void startListening() {
    if (!_isRecording) {
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _speechController?.add(result.recognizedWords);
          }
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
        localeId: 'ko_KR',
        onSoundLevelChange: (level) {
          // 음성 레벨 변화 처리
        },
      );
      _isRecording = true;
    }
  }
  
  // 음성 인식 중지
  void stopListening() {
    if (_isRecording) {
      _speech.stop();
      _isRecording = false;
    }
  }
  
  // 음성 녹음 시작
  Future<void> startRecording() async {
    if (!_isRecording) {
      try {
        if (await _recorder.hasPermission()) {
          await _recorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 44100,
            ),
            path: 'audio_recording.m4a',
          );
          _isRecording = true;
        }
      } catch (e) {
        print('Error starting recording: $e');
      }
    }
  }
  
  // 음성 녹음 중지
  Future<String?> stopRecording() async {
    if (_isRecording) {
      try {
        final path = await _recorder.stop();
        _isRecording = false;
        return path;
      } catch (e) {
        print('Error stopping recording: $e');
        return null;
      }
    }
    return null;
  }
  
  // 음성 재생
  Future<void> playAudio(String audioPath) async {
    if (!_isPlaying) {
      try {
        await _player.play(DeviceFileSource(audioPath));
        _isPlaying = true;
        
        _player.onPlayerComplete.listen((_) {
          _isPlaying = false;
        });
      } catch (e) {
        print('Error playing audio: $e');
      }
    }
  }
  
  // 음성 재생 중지
  Future<void> stopAudio() async {
    if (_isPlaying) {
      await _player.stop();
      _isPlaying = false;
    }
  }
  
  // 음성 인식 스트림 구독
  Stream<String> get speechStream {
    if (_speechController == null) {
      _speechController = StreamController<String>.broadcast();
    }
    return _speechController!.stream;
  }
  
  // 현재 상태 확인
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  
  // 리소스 해제
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _speechController?.close();
  }
}


