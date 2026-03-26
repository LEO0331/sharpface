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
  final _favorites = <String>{};
  final _openAI = OpenAIService(apiKey: const String.fromEnvironment('OPENAI_API_KEY'));
  final _authService = AuthService();
  final _scanRecordService = ScanRecordService();

  String _skinType = '尚未分析';
  String _suggestion = '請先拍攝/上傳照片以取得保養建議。';
  List<String> _concerns = const [];
  bool _guestScanUsed = false;
  bool _hasAnalyzed = false;
  String? _guestPhoneForRecord;

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
      });
      await _saveScanRecord();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _skinType = '混合肌（測試）';
        _suggestion = '目前顯示測試分析結果。建議白天控油保濕並加強防曬，夜間溫和修護。';
        _concerns = const ['痘痘', '黑眼圈'];
        _hasAnalyzed = true;
      });
      await _saveScanRecord();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('分析暫時不可用，已套用測試資料供你繼續檢視流程。')),
      );
    }
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

    return productsAsync.when(
      data: (products) => products.isEmpty ? _testingProductsByConcern(_concerns) : products,
      loading: () => _testingProductsByConcern(_concerns),
      error: (_, _) => _testingProductsByConcern(_concerns),
    );
  }

  List<Product> _testingProductsByConcern(List<String> concerns) {
    final hasAcne = concerns.contains('痘痘');
    final list = <Product>[
      Product(
        id: 'test-1',
        name: hasAcne ? '抗痘修護精華（測試）' : '全能保濕精華（測試）',
        price: hasAcne ? 1090 : 990,
        mainIngredients: hasAcne ? ['杜鵑花酸', 'B5'] : ['玻尿酸', '神經醯胺'],
        rating: 3,
        affiliateUrl: 'https://example.com/test-serum',
        isFeatured: true,
        clickCount: 0,
      ),
      Product(
        id: 'test-2',
        name: '溫和潔面（測試）',
        price: 420,
        mainIngredients: const ['胺基酸', '甘草'],
        rating: 2,
        affiliateUrl: 'https://example.com/test-cleanser',
        isFeatured: false,
        clickCount: 0,
      ),
      Product(
        id: 'test-3',
        name: '日間防曬 SPF50（測試）',
        price: 680,
        mainIngredients: const ['氧化鋅', '維他命E'],
        rating: 2,
        affiliateUrl: 'https://example.com/test-sunscreen',
        isFeatured: false,
        clickCount: 0,
      ),
    ];
    list.sort((a, b) => (b.isFeatured ? 1 : 0) - (a.isFeatured ? 1 : 0));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, authSnapshot) {
        final firebaseUser = authSnapshot.data;
        return Scaffold(
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
                      subtitle: Text('已收藏 ${_favorites.length} 件'),
                    ),
                    if (appUser != null)
                      ListTile(
                        leading: Icon(Icons.show_chart),
                        title: Text('歷史膚質曲線'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HistoryCurvePage(userId: firebaseUser!.uid),
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
                      products: _resolveTableProducts(productsAsync),
                      favorites: _favorites,
                      onToggleFavorite: (id) {
                        setState(() {
                          if (!_favorites.remove(id)) _favorites.add(id);
                        });
                      },
                      onBuy: _openAffiliate,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _AdBanner(hasAcneConcern: _concerns.contains('痘痘')),
              ],
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
  final ValueChanged<String> onToggleFavorite;
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
                    onPressed: () => onToggleFavorite(product.id),
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
  const _AdBanner({required this.hasAcneConcern});

  final bool hasAcneConcern;

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
            child: Text(
              hasAcneConcern
                  ? '精準廣告：推薦抗痘精華與控油潔面。'
                  : '精準廣告：推薦男士保濕與防曬組合。',
            ),
          ),
        ],
      ),
    );
  }
}
