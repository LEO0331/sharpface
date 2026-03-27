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
  final _controllers = <String, TextEditingController>{
    'general': TextEditingController(),
    'acne': TextEditingController(),
    'dryness': TextEditingController(),
    'darkcircle': TextEditingController(),
    'sensitive': TextEditingController(),
    'antiaging': TextEditingController(),
  };

  final _enabled = <String, bool>{};
  final _priority = <String, int>{};

  final _poolLabels = const <String, String>{
    'general': '一般廣告池',
    'acne': '抗痘廣告池',
    'dryness': '乾燥廣告池',
    'darkcircle': '黑眼圈廣告池',
    'sensitive': '敏感肌廣告池',
    'antiaging': '抗老廣告池',
  };

  bool _loadingAds = true;
  bool _savingAds = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAds() async {
    try {
      for (final pool in _controllers.keys) {
        final draft = await _adsService.getDraftConfigOnce(pool);
        final live = await _adsService.getPoolConfigOnce(pool);
        final source = draft.messages.isNotEmpty ? draft : live;
        _controllers[pool]!.text = source.messages.join('\n');
        _enabled[pool] = source.enabled;
        _priority[pool] = source.priority;
      }
    } catch (_) {
      // Keep defaults if no permission or missing docs.
    } finally {
      if (mounted) setState(() => _loadingAds = false);
    }
  }

  AdPoolConfig _buildConfig(String pool) {
    final messages = _controllers[pool]!
        .text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return AdPoolConfig(
      pool: pool,
      messages: messages,
      enabled: _enabled[pool] ?? true,
      priority: _priority[pool] ?? 100,
    );
  }

  Future<void> _saveDrafts() async {
    setState(() => _savingAds = true);
    try {
      for (final pool in _controllers.keys) {
        await _adsService.saveDraftConfig(_buildConfig(pool));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('草稿已儲存。')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('草稿儲存失敗：$e')),
      );
    } finally {
      if (mounted) setState(() => _savingAds = false);
    }
  }

  Future<void> _publishAll() async {
    setState(() => _savingAds = true);
    try {
      for (final pool in _controllers.keys) {
        await _adsService.publishPoolConfig(_buildConfig(pool));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('廣告池已發布。')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發布失敗：$e')),
      );
    } finally {
      if (mounted) setState(() => _savingAds = false);
    }
  }

  void _previewPool(String pool) {
    final config = _buildConfig(pool);
    final label = _poolLabels[pool] ?? pool;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$label 預覽'),
          content: SizedBox(
            width: 420,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text('Enabled: ${config.enabled}'),
                Text('Priority: ${config.priority}'),
                const SizedBox(height: 10),
                ...config.messages.map((m) => Text('• $m')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rollbackPool(String pool) async {
    final history = await _adsService.getPoolHistory(pool, limit: 15);
    if (!mounted) return;

    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('沒有可回滾的歷史版本。')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return ListTile(
              title: Text('版本 ${index + 1} | priority=${item.priority} | enabled=${item.enabled}'),
              subtitle: Text(item.messages.isEmpty ? '無文案' : item.messages.first),
              onTap: () {
                _controllers[pool]!.text = item.messages.join('\n');
                _enabled[pool] = item.enabled;
                _priority[pool] = item.priority;
                setState(() {});
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
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
                _MetricCard(
                  title: '最高 CTR 廣告',
                  value: '${stats.topAdMessage}\nCTR ${(stats.topAdCtr * 100).toStringAsFixed(1)}%',
                ),
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
                        const Text('可設定啟用/停用、排序權重、預覽、草稿、回滾。'),
                        const SizedBox(height: 12),
                        if (_loadingAds)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          )
                        else ...[
                          ..._controllers.entries.map((entry) {
                            final pool = entry.key;
                            final label = _poolLabels[pool] ?? pool;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$label (adConfigs/$pool)'),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SwitchListTile(
                                          value: _enabled[pool] ?? true,
                                          onChanged: (value) => setState(() => _enabled[pool] = value),
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text('啟用'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 120,
                                        child: TextFormField(
                                          initialValue: (_priority[pool] ?? 100).toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(labelText: '權重'),
                                          onChanged: (value) {
                                            _priority[pool] = int.tryParse(value) ?? 0;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextField(
                                    controller: entry.value,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      labelText: '廣告文案 (每行一則)',
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _previewPool(pool),
                                        child: const Text('預覽'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => _rollbackPool(pool),
                                        child: const Text('回滾'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          Wrap(
                            spacing: 10,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _savingAds ? null : _saveDrafts,
                                icon: const Icon(Icons.drafts_outlined),
                                label: const Text('儲存草稿'),
                              ),
                              FilledButton.icon(
                                onPressed: _savingAds ? null : _publishAll,
                                icon: const Icon(Icons.publish_outlined),
                                label: Text(_savingAds ? '發布中...' : '發布到線上'),
                              ),
                            ],
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
