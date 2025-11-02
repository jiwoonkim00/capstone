import 'package:flutter/material.dart';
import 'package:cookduck/main_pages/bottom_nav.dart';
import 'package:cookduck/main_pages/home_screen.dart';
import 'package:cookduck/mypages/myprofile.dart';
import 'package:cookduck/main_pages/myrefrig.dart';
import 'package:cookduck/main_pages/take_picture_screen.dart';

class CookduckMain extends StatefulWidget {
  const CookduckMain({super.key});

  @override
  State<CookduckMain> createState() => _CookduckMainState();
}

class _CookduckMainState extends State<CookduckMain> {
  static const int _homeIndex = 1;

  void _onItemTapped(int index) {
    if (index == _homeIndex) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TakePictureScreen()),
      );
      return;
    }
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Myrefrig()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Myprofile()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(child: MyhomeScreen()),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavItems,
        currentIndex: _homeIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
