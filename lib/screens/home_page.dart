import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_user.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import '../services/openai_service.dart';
import '../services/scan_record_service.dart';
import '../widgets/top_care_guide_card.dart';
import 'admin_dashboard_page.dart';
import 'auth_page.dart';
import 'history_curve_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _random = Random();
  final _favorites = <String>{};
  final _favoriteProducts = <String, Product>{};
  final _openAI = OpenAIService(apiKey: const String.fromEnvironment('OPENAI_API_KEY'));
  final _authService = AuthService();
  final _scanRecordService = ScanRecordService();
  final _favoriteService = FavoriteService();
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<List<Product>>? _cloudFavoritesSubscription;
  final _cloudFavoriteIds = <String>{};
  final _cloudFavoriteProducts = <String, Product>{};

  String _skinType = '尚未分析';
  String _suggestion = '請先拍攝/上傳照片以取得保養建議。';
  List<String> _concerns = const [];
  bool _guestScanUsed = false;
  bool _hasAnalyzed = false;
  bool _useFallbackTestingProducts = false;
  String? _guestPhoneForRecord;
  String _activeAdText = '測試廣告：男士保濕與防曬入門套組。';

  final List<Product> _staticProducts = const [
    Product(
      id: 'static-1',
      name: '控油潔面膠',
      price: 450,
      mainIngredients: ['水楊酸', '菸鹼醯胺'],
      rating: 2,
      affiliateUrl: 'https://example.com/oil-cleanser',
      isFeatured: true,
      clickCount: 0,
    ),
    Product(
      id: 'static-2',
      name: '抗痘精華',
      price: 980,
      mainIngredients: ['杜鵑花酸', '積雪草'],
      rating: 3,
      affiliateUrl: 'https://example.com/acne-serum',
      isFeatured: false,
      clickCount: 0,
    ),
    Product(
      id: 'static-3',
      name: '清爽保濕乳',
      price: 720,
      mainIngredients: ['玻尿酸', '神經醯胺'],
      rating: 2,
      affiliateUrl: 'https://example.com/moisture-lotion',
      isFeatured: false,
      clickCount: 0,
    ),
  ];

  final List<Product> _testingProducts = const [
    Product(id: 'test-1', name: '抗痘修護精華（測試）', price: 1090, mainIngredients: ['杜鵑花酸', 'B5'], rating: 3, affiliateUrl: 'https://example.com/test-serum-1', isFeatured: true, clickCount: 0),
    Product(id: 'test-2', name: '溫和潔面（測試）', price: 420, mainIngredients: ['胺基酸', '甘草'], rating: 2, affiliateUrl: 'https://example.com/test-cleanser-2', isFeatured: false, clickCount: 0),
    Product(id: 'test-3', name: '日間防曬 SPF50（測試）', price: 680, mainIngredients: ['氧化鋅', '維他命E'], rating: 2, affiliateUrl: 'https://example.com/test-sunscreen-3', isFeatured: false, clickCount: 0),
    Product(id: 'test-4', name: '夜間修護乳（測試）', price: 780, mainIngredients: ['神經醯胺', '角鯊烷'], rating: 2, affiliateUrl: 'https://example.com/test-night-4', isFeatured: false, clickCount: 0),
    Product(id: 'test-5', name: '控油化妝水（測試）', price: 390, mainIngredients: ['金縷梅', '鋅 PCA'], rating: 1, affiliateUrl: 'https://example.com/test-toner-5', isFeatured: false, clickCount: 0),
    Product(id: 'test-6', name: '黑眼圈眼部精華（測試）', price: 880, mainIngredients: ['咖啡因', '維他命K'], rating: 3, affiliateUrl: 'https://example.com/test-eye-6', isFeatured: true, clickCount: 0),
    Product(id: 'test-7', name: '敏感修護凝膠（測試）', price: 520, mainIngredients: ['積雪草', '尿囊素'], rating: 2, affiliateUrl: 'https://example.com/test-repair-7', isFeatured: false, clickCount: 0),
    Product(id: 'test-8', name: '泥膜清潔（測試）', price: 460, mainIngredients: ['高嶺土', '鋅'], rating: 1, affiliateUrl: 'https://example.com/test-mask-8', isFeatured: false, clickCount: 0),
    Product(id: 'test-9', name: '清爽乳液（測試）', price: 650, mainIngredients: ['玻尿酸', '維他命B3'], rating: 2, affiliateUrl: 'https://example.com/test-lotion-9', isFeatured: false, clickCount: 0),
    Product(id: 'test-10', name: '男士修護組（測試）', price: 1290, mainIngredients: ['多胜肽', '神經醯胺'], rating: 3, affiliateUrl: 'https://example.com/test-kit-10', isFeatured: true, clickCount: 0),
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
  ];

  final List<String> _generalAds = const [
    '測試廣告：男士保濕防曬雙件組 85 折。',
    '測試廣告：夜間修護霜新客首購折扣。',
    '測試廣告：早晚保養入門組限時加贈。',
  ];

  @override
  void initState() {
    super.initState();
    _authStateSubscription = _authService.authStateChanges().listen(_handleAuthChanged);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _cloudFavoritesSubscription?.cancel();
    super.dispose();
  }

  void _handleAuthChanged(User? user) {
    _cloudFavoritesSubscription?.cancel();
    _cloudFavoriteIds.clear();
    _cloudFavoriteProducts.clear();

    if (user == null) {
      if (mounted) setState(() {});
      return;
    }

    _cloudFavoritesSubscription = _favoriteService.watchFavorites(user.uid).listen((products) {
      _cloudFavoriteIds
        ..clear()
        ..addAll(products.map((e) => e.id));
      _cloudFavoriteProducts
        ..clear()
        ..addEntries(products.map((e) => MapEntry(e.id, e)));
      if (mounted) setState(() {});
    });
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
        _activeAdText = _randomAdByConcerns(result.concerns);
      });
      await _saveScanRecord();
    } catch (_) {
      if (!mounted) return;
      _applyRandomFallbackAnalysis();
      await _saveScanRecord();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('分析暫時不可用，已套用測試資料供你繼續檢視流程。')),
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
      _activeAdText = _randomAdByConcerns(_concerns);
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

  List<Product> _resolveTableProducts(AsyncValue<List<Product>> productsAsync) {
    if (!_hasAnalyzed) return _staticProducts;
    if (_useFallbackTestingProducts) return _testingProducts;

    return productsAsync.when(
      data: (products) => products.isEmpty ? _testingProducts : products,
      loading: () => _testingProducts,
      error: (_, _) => _testingProducts,
    );
  }

  String _randomAdByConcerns(List<String> concerns) {
    final source = concerns.contains('痘痘') ? _acneAds : _generalAds;
    return source[_random.nextInt(source.length)];
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
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('目前尚未加入任何最愛商品。'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteList.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final product = favoriteList[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('價格：\$${product.price.toStringAsFixed(0)}'),
              trailing: TextButton(
                onPressed: () => _openAffiliate(product),
                child: const Text('購買'),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);
    final displayProducts = _resolveTableProducts(productsAsync);

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, authSnapshot) {
        final firebaseUser = authSnapshot.data;
        final activeFavoriteIds = _activeFavoriteIds(firebaseUser);
        return SelectionArea(
          child: Scaffold(
          drawer: StreamBuilder<AppUser?>(
            stream: _authService.watchCurrentAppUser(),
            builder: (context, snapshot) {
              final appUser = snapshot.data;
              return Drawer(
                child: ListView(
                  children: [
                    DrawerHeader(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('男士 AI 護膚分析儀'),
                          const SizedBox(height: 8),
                          Text(firebaseUser?.email ?? '未登入'),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.favorite_outline),
                      title: const Text('我的最愛'),
                      subtitle: Text('已收藏 ${activeFavoriteIds.length} 件'),
                      onTap: () {
                        Navigator.pop(context);
                        _showFavoritesSheet(
                          user: firebaseUser,
                          currentProducts: displayProducts,
                        );
                      },
                    ),
                    if (firebaseUser != null)
                      ListTile(
                        leading: Icon(Icons.show_chart),
                        title: Text('歷史膚質曲線'),
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
                    if (appUser?.isAdmin == true)
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings_outlined),
                        title: const Text('管理後台'),
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
                      title: Text(firebaseUser == null ? '登入 / 註冊' : '登出'),
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
              );
            },
          ),
          appBar: AppBar(
            title: const Text('男士護膚分析儀'),
            actions: [
              TextButton.icon(
                onPressed: _pickAndAnalyze,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('分析照片'),
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
                colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TopCareGuideCard(skinType: _skinType, suggestion: _suggestion),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _ProductTable(
                      products: displayProducts,
                      favorites: activeFavoriteIds,
                      onToggleFavorite: (product) => _toggleFavorite(firebaseUser, product),
                      onBuy: _openAffiliate,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _AdBanner(
                  hasAcneConcern: _concerns.contains('痘痘'),
                  adText: _activeAdText,
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

class _ProductTable extends StatelessWidget {
  const _ProductTable({
    required this.products,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onBuy,
  });

  final List<Product> products;
  final Set<String> favorites;
  final ValueChanged<Product> onToggleFavorite;
  final ValueChanged<Product> onBuy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: products.take(10).map((product) {
        final isFav = favorites.contains(product.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: product.isFeatured ? const Color(0xFFFFF9C4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  Text('價格：\$${product.price.toStringAsFixed(0)}'),
                  Text('主成分：${product.mainIngredients.join(', ')}'),
                  Text('推薦星級：${product.rating}/3'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => onToggleFavorite(product),
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () => onBuy(product),
                    child: const Text('購買'),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AdBanner extends StatelessWidget {
  const _AdBanner({
    required this.hasAcneConcern,
    required this.adText,
  });

  final bool hasAcneConcern;
  final String adText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: hasAcneConcern ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(adText),
          ),
        ],
      ),
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
