import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var db = FirebaseFirestore.instance;
            var data = {
              'categoryName': '커피',
              'isUsed': 'true',
            };
            await db.collection('cafe_category').add(data);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
