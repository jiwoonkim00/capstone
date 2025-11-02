import 'package:flutter/material.dart';

class Bookmark extends StatelessWidget {
  const Bookmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EB87),
      appBar: AppBar(
        backgroundColor: Color(0xFFE8EB87),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('북마크'),
            Image(image: AssetImage('assets/logo.png'), width: 40),
          ],
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      body: Container(
        width: 340,
        height: 500,
        margin: EdgeInsets.all(40),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(175),
          borderRadius: BorderRadius.circular(35),
        ),
      ),
    );
  }
}
