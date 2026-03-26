import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import '../services/ads_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _adsService = AdsService();
  final _acneController = TextEditingController();
  final _generalController = TextEditingController();

  bool _loadingAds = true;
  bool _savingAds = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  @override
  void dispose() {
    _acneController.dispose();
    _generalController.dispose();
    super.dispose();
  }

  Future<void> _loadAds() async {
    try {
      final acne = await _adsService.getPoolOnce('acne');
      final general = await _adsService.getPoolOnce('general');
      _acneController.text = acne.join('\n');
      _generalController.text = general.join('\n');
    } catch (_) {
      // Keep empty text if no permission or missing docs.
    } finally {
      if (mounted) setState(() => _loadingAds = false);
    }
  }

  Future<void> _saveAds() async {
    setState(() => _savingAds = true);
    try {
      final acne = _acneController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final general = _generalController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await _adsService.savePool(pool: 'acne', messages: acne);
      await _adsService.savePool(pool: 'general', messages: general);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('廣告池已儲存到 Firestore。')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('儲存失敗：$e')),
      );
    } finally {
      if (mounted) setState(() => _savingAds = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = AdminService(FirebaseFirestore.instance);

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('管理後台')),
        body: FutureBuilder<AdminDashboardStats>(
          future: service.fetchStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final error = snapshot.error;
              final message = error is AdminPermissionException
                  ? error.message
                  : '載入失敗：$error';
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(message),
                  ),
                ),
              );
            }

            final stats = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MetricCard(title: '總用戶數', value: '${stats.totalUsers}'),
                _MetricCard(title: '今日分析次數', value: '${stats.todayScans}'),
                _MetricCard(title: '點擊量最高產品', value: stats.topProductName),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '廣告池管理 (Firestore)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text('每行一則廣告文案。儲存後首頁跑馬燈會即時同步。'),
                        const SizedBox(height: 12),
                        if (_loadingAds)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          )
                        else ...[
                          TextField(
                            controller: _acneController,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              labelText: '抗痘廣告池 (adConfigs/acne)',
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _generalController,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              labelText: '一般廣告池 (adConfigs/general)',
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _savingAds ? null : _saveAds,
                            icon: const Icon(Icons.save_outlined),
                            label: Text(_savingAds ? '儲存中...' : '儲存廣告池'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: SelectableText(value),
      ),
    );
  }
}
