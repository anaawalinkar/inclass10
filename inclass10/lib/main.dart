import 'package:flutter/material.dart';
import 'package:inclass10/screens/folders_screen.dart';

void main() {
  runApp(const CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  const CardOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FoldersScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}