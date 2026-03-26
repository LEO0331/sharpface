import 'package:flutter/widgets.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('zh', 'TW'), Locale('en')];

  static const _values = {
    'zh': {
      'appTitle': '男士 AI 護膚分析儀',
      'analyzePhoto': '分析照片',
      'searchProduct': '搜尋產品名稱或成分',
      'favorites': '我的最愛',
      'historyCurve': '歷史膚質曲線',
      'adminDashboard': '管理後台',
      'loginRegister': '登入 / 註冊',
      'logout': '登出',
      'notLoggedIn': '未登入',
      'noFavorite': '目前尚未加入任何最愛商品。',
      'buy': '購買',
      'noProduct': '查無符合條件的產品。',
      'analysisUnavailable': '分析暫時不可用，已套用測試資料供你繼續檢視流程。',
    },
    'en': {
      'appTitle': 'Men AI Skin Analyzer',
      'analyzePhoto': 'Analyze Photo',
      'searchProduct': 'Search by product or ingredient',
      'favorites': 'Favorites',
      'historyCurve': 'Skin Trend',
      'adminDashboard': 'Admin Dashboard',
      'loginRegister': 'Login / Register',
      'logout': 'Logout',
      'notLoggedIn': 'Not signed in',
      'noFavorite': 'No favorite products yet.',
      'buy': 'Buy',
      'noProduct': 'No matching products found.',
      'analysisUnavailable': 'Analysis unavailable. Loaded testing result for demo flow.',
    },
  };

  String t(String key) {
    final lang = _values[locale.languageCode] ?? _values['zh']!;
    return lang[key] ?? key;
  }

  static AppStrings of(BuildContext context) {
    final strings = Localizations.of<AppStrings>(context, AppStrings);
    return strings ?? AppStrings(const Locale('zh', 'TW'));
  }
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppStrings.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) async {
    return AppStrings(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
