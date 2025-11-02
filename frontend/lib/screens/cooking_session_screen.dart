import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';
import '../services/voice_service.dart';

class CookingSessionScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final List<String> ingredients;

  const CookingSessionScreen({
    Key? key,
    required this.recipe,
    required this.ingredients,
  }) : super(key: key);

  @override
  _CookingSessionScreenState createState() => _CookingSessionScreenState();
}

class _CookingSessionScreenState extends State<CookingSessionScreen> {
  final ChatService _chatService = ChatService();
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _constraintController = TextEditingController();
  
  String _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  Map<String, dynamic>? _sessionData;
  List<Map<String, dynamic>> _cookingSteps = [];
  int _currentStepIndex = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isVoiceEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _initializeVoice();
  }

  Future<void> _initializeSession() async {
    setState(() => _isLoading = true);
    
    try {
      // 요리 세션 시작
      final result = await ApiService.startCookingSession(_userId, widget.recipe['id'] ?? 1);
      
      setState(() {
        _sessionData = result;
        _isLoading = false;
      });
      
      // 현재 단계 가져오기
      await _getCurrentStep();
    } catch (e) {
      setState(() {
        _errorMessage = '세션 시작에 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVoice() async {
    final available = await _voiceService.initializeSpeech();
    setState(() {
      _isVoiceEnabled = available;
    });
  }

  Future<void> _getCurrentStep() async {
    try {
      final result = await ApiService.getCurrentStep(_userId);
      
      setState(() {
        _cookingSteps = List<Map<String, dynamic>>.from(result['instructions'] ?? []);
        _currentStepIndex = result['step_index'] ?? 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '현재 단계를 불러오는데 실패했습니다: $e';
      });
    }
  }

  Future<void> _getNextStep() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await ApiService.getNextStep(_userId);
      
      setState(() {
        _currentStepIndex = result['step_index'] ?? _currentStepIndex + 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '다음 단계를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addConstraint() async {
    final message = _constraintController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      await ApiService.addConstraint(_userId, message);
      _constraintController.clear();
      
      // 현재 단계 다시 가져오기 (제약사항 반영)
      await _getCurrentStep();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = '제약사항 추가에 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👨‍🍳 ${widget.recipe['title'] ?? '요리 가이드'}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_isVoiceEnabled)
            IconButton(
              icon: Icon(_voiceService.isRecording ? Icons.mic : Icons.mic_none),
              onPressed: _toggleVoiceRecording,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 현재 조리 단계
                  if (_cookingSteps.isNotEmpty && _currentStepIndex < _cookingSteps.length)
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.restaurant, color: Colors.blue),
                                SizedBox(width: 10),
                                Text(
                                  '단계 ${_currentStepIndex + 1}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              _cookingSteps[_currentStepIndex]['text'] ?? 
                              _cookingSteps[_currentStepIndex]['original_step'] ?? 
                              '단계 설명이 없습니다.',
                              style: TextStyle(fontSize: 16),
                            ),
                            if (_cookingSteps[_currentStepIndex]['applied_constraints'] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Wrap(
                                  children: (_cookingSteps[_currentStepIndex]['applied_constraints'] as List)
                                      .map((constraint) => Chip(
                                            label: Text('${constraint['type']}: ${constraint['action']}'),
                                            backgroundColor: Colors.orange.shade100,
                                          ))
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 20),
                  
                  // 제약사항 추가
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '요리 요청사항',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _constraintController,
                                  decoration: InputDecoration(
                                    hintText: '예: 좀 더 매콤하게 해줘',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _addConstraint,
                                child: Text('추가'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            '💡 예시: "매콤하게", "저염으로", "비건으로", "기름 적게"',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // 에러 메시지
                  if (_errorMessage.isNotEmpty)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 10),
                            Expanded(child: Text(_errorMessage, style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    ),
                  
                  Spacer(),
                  
                  // 하단 버튼들
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentStepIndex > 0 ? _getPreviousStep : null,
                          icon: Icon(Icons.arrow_back),
                          label: Text('이전 단계'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getNextStep,
                          icon: Icon(Icons.arrow_forward),
                          label: Text('다음 단계'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _getPreviousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  void _toggleVoiceRecording() {
    if (_voiceService.isRecording) {
      _voiceService.stopListening();
    } else {
      _voiceService.startListening();
    }
  }

  @override
  void dispose() {
    _constraintController.dispose();
    _voiceService.dispose();
    _chatService.disconnect();
    super.dispose();
  }
}


