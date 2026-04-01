import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/cache/local_cache_service.dart';
import '../core/navigation/route_observer.dart';
import '../l10n/app_strings.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../services/ads_service.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import '../services/openai_service.dart';
import '../services/scan_record_service.dart';
import '../widgets/home/ad_marquee_banner.dart';
import '../widgets/home/product_grid.dart';
import '../widgets/home/quick_routine_card.dart';
import '../widgets/top_care_guide_card.dart';
import 'admin_dashboard_page.dart';
import 'auth_page.dart';
import 'history_curve_page.dart';
import 'product_detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with RouteAware {
  final _random = Random();
  final _scrollController = ScrollController();
  final _favorites = <String>{};
  final _favoriteProducts = <String, Product>{};
  final _openAI = OpenAIService(apiKey: const String.fromEnvironment('OPENAI_API_KEY'));
  final _authService = AuthService();
  final _scanRecordService = ScanRecordService();
  final _favoriteService = FavoriteService();
  final _adsService = AdsService();
  final _cache = LocalCacheService();

  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<List<Product>>? _cloudFavoritesSubscription;
  final _adPoolSubscriptions = <StreamSubscription<AdPoolConfig>>[];

  final _cloudFavoriteIds = <String>{};
  final _cloudFavoriteProducts = <String, Product>{};
  final _remoteAdConfigs = <String, AdPoolConfig>{};
  bool _isPageVisible = true;
  bool _routeSubscribed = false;
  double _scrollOffset = 0;
  String? _currentUid;

  bool _isAdmin = false;
  String _skinType = '尚未分析';
  String _suggestion = '請先拍攝/上傳照片以取得保養建議。';
  List<String> _concerns = const [];
  String _searchQuery = '';
  bool _guestScanUsed = false;
  bool _hasAnalyzed = false;
  bool _useFallbackTestingProducts = false;
  String? _guestPhoneForRecord;
  String _activeAdPool = 'general';
  List<String> _activeAds = const ['測試廣告：男士保濕與防曬入門套組。'];
  final Set<String> _seenAdImpressions = <String>{};
  final List<String> _recentViewedIds = <String>[];
  final Map<String, Product> _lastRenderedProducts = <String, Product>{};
  static const _cacheTtl = Duration(minutes: 10);
  BudgetTier _selectedBudget = BudgetTier.balanced;

  static const _adPools = [
    'general',
    'acne',
    'dryness',
    'darkcircle',
    'sensitive',
    'antiaging',
  ];

  final List<Product> _staticProducts = const [
    Product(id: 'static-1', name: '控油潔面膠', price: 450, mainIngredients: ['水楊酸', '菸鹼醯胺'], rating: 2, affiliateUrl: 'https://example.com/oil-cleanser', isFeatured: true, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?auto=format&fit=crop&w=900&q=80'),
    Product(id: 'static-2', name: '抗痘精華', price: 980, mainIngredients: ['杜鵑花酸', '積雪草'], rating: 3, affiliateUrl: 'https://example.com/acne-serum', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1612817159949-195b6eb9e31a?auto=format&fit=crop&w=900&q=80'),
    Product(id: 'static-3', name: '清爽保濕乳', price: 720, mainIngredients: ['玻尿酸', '神經醯胺'], rating: 2, affiliateUrl: 'https://example.com/moisture-lotion', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=900&q=80'),
    Product(id: 'static-4', name: '舒緩修護精華', price: 860, mainIngredients: ['積雪草', '泛醇 B5'], rating: 2, affiliateUrl: 'https://example.com/repair-serum', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=900&q=80'),
    Product(id: 'static-5', name: '日間清爽防曬', price: 690, mainIngredients: ['氧化鋅', '維他命E'], rating: 3, affiliateUrl: 'https://example.com/day-sunscreen', isFeatured: true, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1629198735660-e39ea93f5c18?auto=format&fit=crop&w=900&q=80'),
    Product(id: 'static-6', name: '夜間修護乳霜', price: 930, mainIngredients: ['神經醯胺', '角鯊烷'], rating: 2, affiliateUrl: 'https://example.com/night-cream', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?auto=format&fit=crop&w=900&q=80'),
  ];

  final List<Product> _testingProducts = const [
    Product(id: 'test-1', name: '抗痘修護精華（測試）', price: 1090, mainIngredients: ['杜鵑花酸', 'B5'], rating: 3, affiliateUrl: 'https://shop.example.com/p/test-serum-1', isFeatured: true, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=900&q=80', userScore: 4.6, reviewCount: 182),
    Product(id: 'test-2', name: '溫和潔面（測試）', price: 420, mainIngredients: ['胺基酸', '甘草'], rating: 2, affiliateUrl: 'https://shop.example.com/p/test-cleanser-2', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?auto=format&fit=crop&w=900&q=80', userScore: 4.3, reviewCount: 96),
    Product(id: 'test-3', name: '日間防曬 SPF50（測試）', price: 680, mainIngredients: ['氧化鋅', '維他命E'], rating: 2, affiliateUrl: 'https://shop.example.com/p/test-sunscreen-3', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1619451687485-878a53e28d32?auto=format&fit=crop&w=900&q=80', userScore: 4.4, reviewCount: 128),
    Product(id: 'test-4', name: '夜間修護乳（測試）', price: 780, mainIngredients: ['神經醯胺', '角鯊烷'], rating: 2, affiliateUrl: 'https://shop.example.com/p/test-night-4', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1629198735660-e39ea93f5c18?auto=format&fit=crop&w=900&q=80', userScore: 4.2, reviewCount: 72),
    Product(id: 'test-5', name: '控油化妝水（測試）', price: 390, mainIngredients: ['金縷梅', '鋅 PCA'], rating: 1, affiliateUrl: 'https://shop.example.com/p/test-toner-5', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1599305090598-fe179d501227?auto=format&fit=crop&w=900&q=80', userScore: 4.0, reviewCount: 64),
    Product(id: 'test-6', name: '黑眼圈眼部精華（測試）', price: 880, mainIngredients: ['咖啡因', '維他命K'], rating: 3, affiliateUrl: 'https://shop.example.com/p/test-eye-6', isFeatured: true, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1612817288484-6f916006741a?auto=format&fit=crop&w=900&q=80', userScore: 4.7, reviewCount: 143),
    Product(id: 'test-7', name: '敏感修護凝膠（測試）', price: 520, mainIngredients: ['積雪草', '尿囊素'], rating: 2, affiliateUrl: 'https://shop.example.com/p/test-repair-7', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1629738355957-f4ebd6b0dd3d?auto=format&fit=crop&w=900&q=80', userScore: 4.1, reviewCount: 59),
    Product(id: 'test-8', name: '泥膜清潔（測試）', price: 460, mainIngredients: ['高嶺土', '鋅'], rating: 1, affiliateUrl: 'https://shop.example.com/p/test-mask-8', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?auto=format&fit=crop&w=900&q=80', userScore: 3.9, reviewCount: 44),
    Product(id: 'test-9', name: '清爽乳液（測試）', price: 650, mainIngredients: ['玻尿酸', '維他命B3'], rating: 2, affiliateUrl: 'https://shop.example.com/p/test-lotion-9', isFeatured: false, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1611930022073-b7a4ba5fcccd?auto=format&fit=crop&w=900&q=80', userScore: 4.3, reviewCount: 118),
    Product(id: 'test-10', name: '男士修護組（測試）', price: 1290, mainIngredients: ['多胜肽', '神經醯胺'], rating: 3, affiliateUrl: 'https://shop.example.com/p/test-kit-10', isFeatured: true, clickCount: 0, imageUrl: 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?auto=format&fit=crop&w=900&q=80', userScore: 4.8, reviewCount: 207),
  ];

  final List<_FallbackAnalysis> _fallbackAnalyses = const [
    _FallbackAnalysis(skinType: '混合肌（測試）', suggestion: '白天輕保濕+防曬，晚間溫和清潔。', concerns: ['痘痘', '黑眼圈']),
    _FallbackAnalysis(skinType: '油性肌（測試）', suggestion: '加強控油與角質代謝，避免厚重乳霜。', concerns: ['痘痘', '毛孔粗大']),
    _FallbackAnalysis(skinType: '乾性肌（測試）', suggestion: '提升保濕層次，睡前加強修護。', concerns: ['乾燥', '脫皮']),
    _FallbackAnalysis(skinType: '敏感肌（測試）', suggestion: '降低刺激，優先修護屏障配方。', concerns: ['泛紅', '乾癢']),
    _FallbackAnalysis(skinType: '混合肌（測試）', suggestion: 'T 字控油，雙頰加保濕，日間一定防曬。', concerns: ['出油', '黑頭']),
    _FallbackAnalysis(skinType: '油性肌（測試）', suggestion: '晨間溫和潔面，晚間抗痘修護。', concerns: ['痘痘', '粉刺']),
    _FallbackAnalysis(skinType: '乾性肌（測試）', suggestion: '清潔減量，乳霜與精華分層補水。', concerns: ['細紋', '乾燥']),
    _FallbackAnalysis(skinType: '混合肌（測試）', suggestion: '平衡油水平衡，避免過度清潔。', concerns: ['黑眼圈', '暗沉']),
    _FallbackAnalysis(skinType: '敏感肌（測試）', suggestion: '選擇無香精產品，建立穩定日常。', concerns: ['泛紅', '刺癢']),
    _FallbackAnalysis(skinType: '油性肌（測試）', suggestion: '白天清爽防曬，夜間局部抗痘。', concerns: ['痘痘', '黑眼圈']),
  ];

  final List<String> _acneAds = const [
    '測試廣告：抗痘精華買一送一，限時 48 小時。',
    '測試廣告：控油潔面+抗痘凝膠組合 79 折。',
    '測試廣告：痘痘急救貼滿額免運。',
    '測試廣告：夜間抗痘修護 2 件 75 折。',
    '測試廣告：毛孔淨化組合，下單送旅行包。',
    '測試廣告：痘肌專屬客服諮詢，首購折 100。',
  ];
  final List<String> _generalAds = const [
    '測試廣告：男士保濕防曬雙件組 85 折。',
    '測試廣告：夜間修護霜新客首購折扣。',
    '測試廣告：早晚保養入門組限時加贈。',
    '測試廣告：清爽乳液本週熱銷榜前 3。',
    '測試廣告：敏感肌舒緩套裝滿千免運。',
    '測試廣告：會員日加碼回饋 5%。',
  ];
  final List<String> _drynessAds = const [
    '測試廣告：高保濕修護乳，乾燥季限定折扣。',
    '測試廣告：神經醯胺鎖水精華第二件半價。',
    '測試廣告：乾肌夜間修護組送面膜 2 片。',
  ];
  final List<String> _darkcircleAds = const [
    '測試廣告：眼周亮白精華，黑眼圈專案價。',
    '測試廣告：咖啡因眼部凝膠新客 8 折。',
    '測試廣告：晚安眼膜組合買二送一。',
  ];
  final List<String> _sensitiveAds = const [
    '測試廣告：敏感肌舒緩組，無香精低刺激。',
    '測試廣告：修護屏障乳，首購現折 120。',
    '測試廣告：泛紅急救組限時免運。',
  ];
  final List<String> _antiagingAds = const [
    '測試廣告：抗老精華體驗組本週 79 折。',
    '測試廣告：胜肽修護乳，會員點數雙倍。',
    '測試廣告：夜間緊緻組合加贈旅行瓶。',
  ];

  final Map<String, List<String>> _testingReviews = const {
    'test-1': ['控油效果明顯，一週有感。', '晚上擦隔天痘痘紅腫有降。'],
    'test-2': ['不緊繃、清潔力剛好。', '敏感時期也可用。'],
    'test-3': ['不泛白，通勤很實用。', '清爽不黏膩。'],
    'test-6': ['黑眼圈看起來有淡一點。', '質地清爽好吸收。'],
    'test-10': ['一組搞定早晚流程。', '送禮也不錯。'],
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!mounted) return;
      final next = _scrollController.hasClients ? _scrollController.offset : 0.0;
      if ((next - _scrollOffset).abs() < 10) return;
      setState(() => _scrollOffset = next);
    });
    _authStateSubscription = _authService.authStateChanges().listen(_handleAuthChanged);
    _loadAdCache();
    _startAdSubscriptions();
    _preloadFirstScreen();
    _activeAds = _adsByConcerns(_concerns);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_routeSubscribed && route != null) {
      appRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _scrollController.dispose();
    _authStateSubscription?.cancel();
    _cloudFavoritesSubscription?.cancel();
    _stopAdSubscriptions();
    super.dispose();
  }

  @override
  void didPushNext() {
    _isPageVisible = false;
    _cloudFavoritesSubscription?.cancel();
    _cloudFavoritesSubscription = null;
    _stopAdSubscriptions();
  }

  @override
  void didPopNext() {
    _isPageVisible = true;
    _startAdSubscriptions();
    if (_currentUid != null) {
      _startFavoritesSubscription(_currentUid!);
    }
  }

  void _handleAuthChanged(User? user) {
    _cloudFavoriteIds.clear();
    _cloudFavoriteProducts.clear();
    _currentUid = user?.uid;

    if (user == null) {
      _isAdmin = false;
      _cloudFavoritesSubscription?.cancel();
      _cloudFavoritesSubscription = null;
      if (mounted) setState(_resetToInitialView);
      return;
    }

    _loadFavoritesCache(user.uid);
    if (_isPageVisible) _startFavoritesSubscription(user.uid);

    _authService.isAdmin(user.uid).then((isAdmin) {
      _isAdmin = isAdmin;
      if (mounted) setState(() {});
    }).catchError((_) {
      _isAdmin = false;
      if (mounted) setState(() {});
    });
  }

  void _startFavoritesSubscription(String uid) {
    _cloudFavoritesSubscription?.cancel();
    _cloudFavoritesSubscription = _favoriteService.watchFavorites(uid).listen((products) {
      _cloudFavoriteIds
        ..clear()
        ..addAll(products.map((e) => e.id));
      _cloudFavoriteProducts
        ..clear()
        ..addEntries(products.map((e) => MapEntry(e.id, e)));
      if (mounted) setState(() {});
    });
  }

  void _startAdSubscriptions() {
    _stopAdSubscriptions();
    for (final pool in _adPools) {
      final sub = _adsService.watchPoolConfig(pool).listen((config) {
        _remoteAdConfigs[pool] = config;
        _cache.saveIfChanged('adConfig_$pool', config.toMap()).then((changed) {
          if (changed) {
            _cache.saveJsonWithTtl(
              key: 'adConfig_$pool',
              value: config.toMap(),
              ttl: _cacheTtl,
            );
          }
        });
        if (mounted) setState(() => _activeAds = _adsByConcerns(_concerns));
      });
      _adPoolSubscriptions.add(sub);
    }
  }

  void _stopAdSubscriptions() {
    for (final sub in _adPoolSubscriptions) {
      sub.cancel();
    }
    _adPoolSubscriptions.clear();
  }

  Future<void> _loadAdCache() async {
    for (final pool in _adPools) {
      final data = await _cache.readFreshJsonMap('adConfig_$pool');
      if (data != null) {
        _remoteAdConfigs[pool] = AdPoolConfig.fromDoc(pool, data);
      }
    }
    final recentIds = await _cache.readFreshJsonList('recent_viewed_ids');
    _recentViewedIds
      ..clear()
      ..addAll((recentIds ?? const <dynamic>[]).whereType<String>());
    if (mounted) setState(() {});
  }

  Future<void> _loadFavoritesCache(String uid) async {
    final cached = await _favoriteService.readCachedFavorites(uid);
    _cloudFavoriteIds
      ..clear()
      ..addAll(cached.map((e) => e.id));
    _cloudFavoriteProducts
      ..clear()
      ..addEntries(cached.map((e) => MapEntry(e.id, e)));
    if (mounted) setState(() {});
  }

  void _resetToInitialView() {
    _skinType = '尚未分析';
    _suggestion = '請先拍攝/上傳照片以取得保養建議。';
    _concerns = const [];
    _searchQuery = '';
    _guestScanUsed = false;
    _hasAnalyzed = false;
    _useFallbackTestingProducts = false;
    _guestPhoneForRecord = null;
    _activeAdPool = 'general';
    _seenAdImpressions.clear();
    _activeAds = _adsByConcerns(const []);
  }

  Future<void> _pickAndAnalyze() async {
    final canScan = await _ensureScanPermission();
    if (!canScan) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    await _runAnalysis(bytes);
  }

  Future<bool> _ensureScanPermission() async {
    if (FirebaseAuth.instance.currentUser != null) return true;

    if (_guestScanUsed) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('訪客僅可掃描一次，請先註冊登入。')),
      );
      return false;
    }

    final verified = await _showGuestPhoneOtpDialog();
    if (verified) _guestScanUsed = true;
    return verified;
  }

  Future<bool> _showGuestPhoneOtpDialog() async {
    final phoneController = TextEditingController();
    final codeController = TextEditingController();

    bool sending = false;
    bool verifying = false;
    bool sent = false;
    String message = '請輸入手機號碼（含國碼，例如 +8869xxxxxxxx）。';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            return AlertDialog(
              title: const Text('訪客 SMS OTP 驗證'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: '手機號碼'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'OTP 驗證碼'),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        message,
                        style: Theme.of(dialogContext).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: sending
                      ? null
                      : () async {
                          setLocalState(() {
                            sending = true;
                            message = 'OTP 發送中...';
                          });

                          await _authService.sendGuestPhoneOtp(
                            phoneNumber: phoneController.text.trim(),
                            onCodeSent: () {
                              if (!dialogContext.mounted) return;
                              setLocalState(() {
                                sent = true;
                                message = '已送出 OTP，請輸入驗證碼。';
                              });
                            },
                            onFailed: (error) {
                              if (!dialogContext.mounted) return;
                              setLocalState(() => message = '發送失敗：$error');
                            },
                          );

                          if (!dialogContext.mounted) return;
                          setLocalState(() => sending = false);
                        },
                  child: sending ? const Text('發送中') : const Text('發送 OTP'),
                ),
                FilledButton(
                  onPressed: (!sent || verifying)
                      ? null
                      : () async {
                          setLocalState(() {
                            verifying = true;
                            message = '驗證中...';
                          });

                          final ok = await _authService.verifyGuestPhoneOtp(
                            phoneNumber: phoneController.text.trim(),
                            smsCode: codeController.text.trim(),
                          );

                          if (!dialogContext.mounted) return;
                          if (!ok) {
                            setLocalState(() {
                              verifying = false;
                              message = '驗證失敗，請確認 OTP 是否正確。';
                            });
                            return;
                          }

                          _guestPhoneForRecord = phoneController.text.trim();
                          Navigator.pop(dialogContext, true);
                        },
                  child: verifying ? const Text('驗證中') : const Text('驗證並繼續'),
                ),
              ],
            );
          },
        );
      },
    );

    phoneController.dispose();
    codeController.dispose();
    return result ?? false;
  }

  Future<void> _runAnalysis(Uint8List bytes) async {
    try {
      final result = await _openAI.analyzeSkinImage(bytes);
      if (!mounted) return;
      setState(() {
        _skinType = result.skinType;
        _suggestion = result.suggestion;
        _concerns = result.concerns;
        _hasAnalyzed = true;
        _useFallbackTestingProducts = false;
        _activeAds = _adsByConcerns(result.concerns);
      });
      await _saveScanRecord();
    } catch (_) {
      if (!mounted) return;
      _applyRandomFallbackAnalysis();
      await _saveScanRecord();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).t('analysisUnavailable'))),
      );
    }
  }

  void _applyRandomFallbackAnalysis() {
    final pick = _fallbackAnalyses[_random.nextInt(_fallbackAnalyses.length)];
    setState(() {
      _skinType = pick.skinType;
      _suggestion = pick.suggestion;
      _concerns = pick.concerns;
      _hasAnalyzed = true;
      _useFallbackTestingProducts = true;
      _activeAds = _adsByConcerns(_concerns);
    });
  }

  Future<void> _saveScanRecord() async {
    final user = FirebaseAuth.instance.currentUser;
    await _scanRecordService.addScanRecord(
      userId: user?.uid ?? 'guest',
      skinType: _skinType,
      suggestion: _suggestion,
      concerns: _concerns,
      contact: user?.email ?? _guestPhoneForRecord,
    );
  }

  Future<void> _openAffiliate(Product product) async {
    final uri = Uri.tryParse(product.affiliateUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    try {
      await ref.read(productRepositoryProvider).increaseClickCount(product.id);
    } catch (_) {
      // Ignore click count update failures for static/testing products.
    }
  }

  void _openProductDetail(Product product) {
    _rememberViewed(product.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          product: product,
          reviews: _testingReviews[product.id] ?? const [],
          similarProducts: _similarProducts(product),
          recentProducts: _recentProducts(excludeId: product.id),
          onOpenProduct: _openProductDetail,
          onBuy: () => _openAffiliate(product),
        ),
      ),
    );
  }

  void _rememberViewed(String productId) {
    _recentViewedIds.remove(productId);
    _recentViewedIds.insert(0, productId);
    if (_recentViewedIds.length > 12) {
      _recentViewedIds.removeRange(12, _recentViewedIds.length);
    }
    _cache.saveJsonWithTtl(
      key: 'recent_viewed_ids',
      value: _recentViewedIds,
      ttl: _cacheTtl,
    );
  }

  List<Product> _similarProducts(Product base) {
    final all = {
      ..._favoriteProducts,
      ..._cloudFavoriteProducts,
      ..._lastRenderedProducts,
    };
    for (final p in _staticProducts) {
      all[p.id] = p;
    }
    for (final p in _testingProducts) {
      all[p.id] = p;
    }
    final candidates = all.values.where((p) => p.id != base.id).toList();
    candidates.sort((a, b) {
      final scoreA = _similarityScore(base, a);
      final scoreB = _similarityScore(base, b);
      return scoreB.compareTo(scoreA);
    });
    return candidates.take(4).toList();
  }

  int _similarityScore(Product a, Product b) {
    final shared = a.mainIngredients.where((i) => b.mainIngredients.contains(i)).length;
    final ratingGap = (a.rating - b.rating).abs();
    return shared * 10 - ratingGap;
  }

  List<Product> _recentProducts({String? excludeId}) {
    final all = <String, Product>{
      for (final p in _staticProducts) p.id: p,
      for (final p in _testingProducts) p.id: p,
      ..._favoriteProducts,
      ..._cloudFavoriteProducts,
    };
    return _recentViewedIds
        .where((id) => id != excludeId)
        .map((id) => all[id])
        .whereType<Product>()
        .take(4)
        .toList();
  }

  String _adTrackingUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return user.uid;
    final phone = _guestPhoneForRecord?.trim();
    if (phone != null && phone.isNotEmpty) return 'guest:$phone';
    return 'guest:anonymous';
  }

  Future<void> _trackAdImpression(String adMessage) async {
    final key = '${_activeAdPool}_$adMessage';
    if (_seenAdImpressions.contains(key)) return;
    _seenAdImpressions.add(key);
    try {
      await _adsService.trackAdImpression(
        pool: _activeAdPool,
        message: adMessage,
        userId: _adTrackingUserId(),
      );
    } catch (_) {
      // Ignore analytics write failures.
    }
  }

  Future<void> _trackAdClick(String adMessage) async {
    try {
      await _adsService.trackAdClick(
        pool: _activeAdPool,
        message: adMessage,
        userId: _adTrackingUserId(),
      );
    } catch (_) {
      // Ignore analytics write failures.
    }
  }

  Future<void> _goAuthPage() async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
    if (!mounted) return;
    if (success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登入/註冊成功')),
      );
    }
    setState(() {});
  }

  List<Product> _resolveProducts(AsyncValue<List<Product>> productsAsync) {
    if (!_hasAnalyzed) return _staticProducts;
    if (_useFallbackTestingProducts) return _testingProducts;

    return productsAsync.when(
      data: (products) => products.isEmpty ? _testingProducts : products,
      loading: () => const [],
      error: (_, _) => _testingProducts,
    );
  }

  Future<void> _preloadFirstScreen() async {
    try {
      final products = await ref.read(productProvider.future);
      if (!mounted) return;
      final firstBatch = products.take(6);
      for (final p in firstBatch) {
        final url = p.imageUrl;
        if (url == null || url.isEmpty) continue;
        await precacheImage(NetworkImage(url), context);
      }

      final generalAdPool = await _adsService.getPoolConfigOnce('general');
      await _cache.saveJsonWithTtl(
        key: 'adConfig_general',
        value: generalAdPool.toMap(),
        ttl: _cacheTtl,
      );
    } catch (_) {
      // Preload is best-effort only.
    }
  }

  List<String> _adsByConcerns(List<String> concerns) {
    final pool = _selectAdPool(concerns);
    _activeAdPool = pool;
    final config = _remoteAdConfigs[pool];
    final source = (config != null && config.isActiveAt(DateTime.now()) && config.messages.isNotEmpty)
        ? config.messages
        : _fallbackAdsByPool(pool);
    final shuffled = [...source]..shuffle(_random);
    return shuffled.take(5).toList();
  }

  String _selectAdPool(List<String> concerns) {
    final candidates = <String>{'general'};
    if (concerns.contains('痘痘')) candidates.add('acne');
    if (concerns.contains('黑眼圈')) candidates.add('darkcircle');
    if (concerns.contains('乾燥') || concerns.contains('脫皮')) candidates.add('dryness');
    if (concerns.contains('泛紅') || concerns.contains('刺癢')) candidates.add('sensitive');
    if (concerns.contains('細紋') || concerns.contains('暗沉')) candidates.add('antiaging');

    String selected = 'general';
    var selectedPriority = -9999;

    for (final pool in candidates) {
      final config = _remoteAdConfigs[pool];
      final enabled = config?.isActiveAt(DateTime.now()) ?? true;
      if (!enabled) continue;
      final priority = config?.priority ?? (pool == 'general' ? 10 : 100);
      if (priority > selectedPriority) {
        selectedPriority = priority;
        selected = pool;
      }
    }
    return selected;
  }

  List<String> _fallbackAdsByPool(String pool) {
    switch (pool) {
      case 'acne':
        return _acneAds;
      case 'dryness':
        return _drynessAds;
      case 'darkcircle':
        return _darkcircleAds;
      case 'sensitive':
        return _sensitiveAds;
      case 'antiaging':
        return _antiagingAds;
      default:
        return _generalAds;
    }
  }

  Set<String> _activeFavoriteIds(User? user) {
    return user == null ? _favorites : _cloudFavoriteIds;
  }

  Map<String, Product> _activeFavoriteProducts(User? user) {
    return user == null ? _favoriteProducts : _cloudFavoriteProducts;
  }

  Future<void> _toggleFavorite(User? user, Product product) async {
    if (user == null) {
      setState(() {
        if (_favorites.remove(product.id)) {
          _favoriteProducts.remove(product.id);
        } else {
          _favorites.add(product.id);
          _favoriteProducts[product.id] = product;
        }
      });
      return;
    }

    final isFavorite = _cloudFavoriteIds.contains(product.id);
    if (isFavorite) {
      await _favoriteService.removeFavorite(uid: user.uid, productId: product.id);
    } else {
      await _favoriteService.addFavorite(uid: user.uid, product: product);
    }
  }

  Future<void> _showFavoritesSheet({
    required User? user,
    required List<Product> currentProducts,
  }) async {
    final activeIds = _activeFavoriteIds(user);
    final activeProducts = _activeFavoriteProducts(user);
    final byId = <String, Product>{
      ...{for (final product in currentProducts) product.id: product},
      ...activeProducts,
    };
    final favoriteList = activeIds.map((id) => byId[id]).whereType<Product>().toList();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        if (favoriteList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(AppStrings.of(context).t('noFavorite')),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteList.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final product = favoriteList[index];
            return ListTile(
              leading: product.imageUrl == null
                  ? null
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        product.imageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
              title: Text(product.name),
              subtitle: Text('價格：\$${product.price.toStringAsFixed(0)}'),
              trailing: TextButton(
                onPressed: () => _openAffiliate(product),
                child: Text(AppStrings.of(context).t('buy')),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReveal({
    required Widget child,
    required double triggerOffset,
  }) {
    final visible = _scrollOffset + 520 >= triggerOffset;
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 0.08),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);
    final displayProducts = _resolveProducts(productsAsync);
    final showProductSkeleton =
        _hasAnalyzed && !_useFallbackTestingProducts && productsAsync.isLoading;
    final filteredProducts = displayProducts.where((product) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return product.name.toLowerCase().contains(q) ||
          product.mainIngredients.any((i) => i.toLowerCase().contains(q));
    }).toList();
    _lastRenderedProducts
      ..clear()
      ..addEntries(filteredProducts.map((e) => MapEntry(e.id, e)));

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, authSnapshot) {
        final firebaseUser = authSnapshot.data;
        final activeFavoriteIds = _activeFavoriteIds(firebaseUser);
        return SelectionArea(
          child: Scaffold(
            drawer: Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.of(context).t('appTitle')),
                        const SizedBox(height: 8),
                        Text(firebaseUser?.email ?? AppStrings.of(context).t('notLoggedIn')),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline),
                    title: Text(AppStrings.of(context).t('favorites')),
                    subtitle: Text('已收藏 ${activeFavoriteIds.length} 件'),
                    onTap: () {
                      Navigator.pop(context);
                      _showFavoritesSheet(
                        user: firebaseUser,
                        currentProducts: filteredProducts,
                      );
                    },
                  ),
                  if (firebaseUser != null)
                    ListTile(
                      leading: const Icon(Icons.show_chart),
                      title: Text(AppStrings.of(context).t('historyCurve')),
                      onTap: () {
                        final userId = firebaseUser.uid;
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistoryCurvePage(userId: userId),
                          ),
                        );
                      },
                    ),
                  if (_isAdmin)
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      title: Text(AppStrings.of(context).t('adminDashboard')),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                        );
                      },
                    ),
                  const Divider(),
                  ListTile(
                    leading: Icon(firebaseUser == null ? Icons.login : Icons.logout),
                    title: Text(
                      firebaseUser == null
                          ? AppStrings.of(context).t('loginRegister')
                          : AppStrings.of(context).t('logout'),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      if (firebaseUser == null) {
                        await _goAuthPage();
                        return;
                      }
                      await _authService.signOut();
                    },
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              title: Text(AppStrings.of(context).t('appTitle')),
              actions: [
                TextButton.icon(
                  onPressed: _pickAndAnalyze,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(AppStrings.of(context).t('analyzePhoto')),
                ),
                IconButton(
                  tooltip: firebaseUser == null ? '登入/註冊' : '登出',
                  onPressed: () async {
                    if (firebaseUser == null) {
                      await _goAuthPage();
                      return;
                    }
                    await _authService.signOut();
                  },
                  icon: Icon(firebaseUser == null ? Icons.person_outline : Icons.logout),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8F6FF), Color(0xFFEEF4FF), Color(0xFFF6FAFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildReveal(
                    triggerOffset: 0,
                    child: TopCareGuideCard(skinType: _skinType, suggestion: _suggestion),
                  ),
                  if (_hasAnalyzed) ...[
                    const SizedBox(height: 12),
                    _buildReveal(
                      triggerOffset: 60,
                      child: QuickRoutineCard(
                        skinType: _skinType,
                        concerns: _concerns,
                        suggestion: _suggestion,
                        selectedBudget: _selectedBudget,
                        onBudgetChanged: (tier) => setState(() => _selectedBudget = tier),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildReveal(
                    triggerOffset: 110,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: AppStrings.of(context).t('searchProduct'),
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildReveal(
                    triggerOffset: 220,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ProductGrid(
                          products: filteredProducts,
                          isLoading: showProductSkeleton,
                          favorites: activeFavoriteIds,
                          reviewSamples: _testingReviews,
                          onToggleFavorite: (product) => _toggleFavorite(firebaseUser, product),
                          onBuy: _openAffiliate,
                          onOpenDetail: _openProductDetail,
                          buyLabel: AppStrings.of(context).t('buy'),
                          noProductText: AppStrings.of(context).t('noProduct'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildReveal(
                    triggerOffset: 440,
                    child: AdMarqueeBanner(
                      hasAcneConcern: _concerns.contains('痘痘'),
                      adMessages: _activeAds,
                      onAdImpression: _trackAdImpression,
                      onAdClick: (message) {
                        _trackAdClick(message);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已記錄廣告點擊：$message')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FallbackAnalysis {
  const _FallbackAnalysis({
    required this.skinType,
    required this.suggestion,
    required this.concerns,
  });

  final String skinType;
  final String suggestion;
  final List<String> concerns;
}
