import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/admin_service.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

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
