import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';

import 'features/scan/presentation/home_screen.dart';

class WordCatcherApp extends StatelessWidget {
  const WordCatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '拍沃德',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
