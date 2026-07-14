import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';

import 'features/shell/presentation/app_shell.dart';

class WordCatcherApp extends StatelessWidget {
  const WordCatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '词光里',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}
