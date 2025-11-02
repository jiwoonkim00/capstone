import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cookduck/main_pages/recipe_result_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookduck/config/api_config.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key}) : super(key: key);

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  List<String> seasonings = [];

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
      });
      await _analyzeImage();
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      await _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. userId 불러오기
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      print('조미료 API 요청 userId: $userId');
      if (userId.isEmpty) throw Exception('userId를 찾을 수 없습니다.');

      // 2. 조미료 API 호출
      final url = '${ApiConfig.springApiBase}/user-seasonings/$userId';
      final response = await http.get(Uri.parse(url));
      print('조미료 API 응답: \\n${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<String> result = [];
        if (data is Map<String, dynamic>) {
          data.forEach((key, value) {
            if (value == true) {
              result.add(key);
            }
          });
        }
        seasonings = result;
      } else {
        throw Exception('조미료 정보를 불러오지 못했습니다.');
      }

      // 3. 이미지 분석(식재료) API 호출
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.externalImageAnalysisUrl),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );
      var responseData = await request.send();
      var responseDataString = await responseData.stream.bytesToString();
      print('식재료 분석 API 응답: \\n$responseDataString');
      var ingredients = List<String>.from(json.decode(responseDataString));

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => RecipeResultScreen(
                ingredients: ingredients,
                seasonings: seasonings,
                recipes: [
                  {'title': '레시피 제목1', 'desc': '내용'},
                  {'title': '레시피 제목2', 'desc': '내용'},
                  {'title': '레시피 제목3', 'desc': '내용'},
                  {'title': '레시피 제목4', 'desc': '내용'},
                  {'title': '레시피 제목5', 'desc': '내용'},
                ],
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 분석 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EB87),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8EB87),
        elevation: 0,
        title: const Text('사진 촬영', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Color(0xFF1EA7FF), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        _image == null
                            ? const Center(
                              child: Text(
                                '사진을 촬영해 주세요.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(
                                File(_image!.path),
                                width: 250,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '음식 사진을 촬영해 주세요!\n촬영된 사진은 미리보기로 확인할 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library, size: 28),
                            label: const Text(
                              '갤러리',
                              style: TextStyle(fontSize: 20),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDEDDC),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _isLoading ? null : _pickFromGallery,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt, size: 28),
                            label: const Text(
                              '촬영하기',
                              style: TextStyle(fontSize: 20),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1EA7FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _isLoading ? null : _takePicture,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
