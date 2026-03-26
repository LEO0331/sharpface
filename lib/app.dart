import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/navigation/route_observer.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_strings.dart';
import 'screens/home_page.dart';

class SharpFaceApp extends StatelessWidget {
  const SharpFaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '護膚分析儀',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppStrings.supportedLocales,
      navigatorObservers: [appRouteObserver],
      home: const HomePage(),
    );
  }
}
