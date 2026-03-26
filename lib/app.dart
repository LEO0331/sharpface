import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_page.dart';

class SharpFaceApp extends StatelessWidget {
  const SharpFaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '護膚分析儀',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return SelectionArea(child: child ?? const SizedBox.shrink());
      },
      home: const HomePage(),
    );
  }
}
