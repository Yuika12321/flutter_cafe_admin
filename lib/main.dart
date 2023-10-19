import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_cafe_admin/cafe_order.dart';
import 'package:flutter_cafe_admin/cafe_item.dart';
import 'package:flutter_cafe_admin/cafe_result.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Navi());
}

class Navi extends StatefulWidget {
  const Navi({super.key});

  @override
  State<Navi> createState() => _NaviState();
}

class _NaviState extends State<Navi> {
  int _index = 1;
  List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.shopping_basket_outlined),
      label: 'order',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.golf_course_rounded),
      label: 'items',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.restore_from_trash_outlined),
      label: 'result',
    ),
  ];
  // pages => bottomnavi와 매핑
  var pages = [const CafeOrder(), const CafeItem(), const CafeResult()];
  dynamic body;
  @override
  void initState() {
    super.initState();
    body = pages[1];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          items: items,
          currentIndex: _index,
          onTap: (value) {
            setState(() {
              body = pages[value];
              _index = value;
            });
          },
        ),
      ),
    );
  }
}
