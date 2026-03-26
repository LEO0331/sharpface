import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/scan_record.dart';
import '../services/scan_record_service.dart';

class HistoryCurvePage extends StatefulWidget {
  const HistoryCurvePage({
    super.key,
    required this.userId,
    this.recordsStream,
  });

  final String userId;
  final Stream<List<ScanRecord>>? recordsStream;

  @override
  State<HistoryCurvePage> createState() => _HistoryCurvePageState();
}

enum _RangeFilter { days7, days30, all }

class _HistoryCurvePageState extends State<HistoryCurvePage> {
  _RangeFilter _selected = _RangeFilter.days7;

  @override
  Widget build(BuildContext context) {
    final recordsStream = widget.recordsStream ?? ScanRecordService().watchUserRecords(widget.userId);

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('歷史膚質曲線')),
        body: StreamBuilder<List<ScanRecord>>(
          stream: recordsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('讀取失敗：${snapshot.error}'));
            }

            final records = snapshot.data ?? const [];
            final filtered = _applyRange(records);
            if (filtered.isEmpty) {
              return const Center(child: Text('目前沒有掃描紀錄。'));
            }

            final spots = <FlSpot>[];
            for (var i = 0; i < filtered.length; i++) {
              spots.add(FlSpot(i.toDouble(), _skinScore(filtered[i]).toDouble()));
            }
            final maxX = filtered.length <= 1 ? 1.0 : (filtered.length - 1).toDouble();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('7 天'),
                            selected: _selected == _RangeFilter.days7,
                            onSelected: (_) => setState(() => _selected = _RangeFilter.days7),
                          ),
                          ChoiceChip(
                            label: const Text('30 天'),
                            selected: _selected == _RangeFilter.days30,
                            onSelected: (_) => setState(() => _selected = _RangeFilter.days30),
                          ),
                          ChoiceChip(
                            label: const Text('全部'),
                            selected: _selected == _RangeFilter.all,
                            onSelected: (_) => setState(() => _selected = _RangeFilter.all),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '近 ${filtered.length} 次膚況趨勢',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: maxX,
                            minY: 0,
                            maxY: 10,
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 26,
                                  interval: _labelInterval(filtered.length),
                                  getTitlesWidget: (value, meta) {
                                    final index = value.round();
                                    if (index < 0 || index >= filtered.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        _formatDate(filtered[index].createdAt),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                barWidth: 3,
                                color: const Color(0xFF0EA5A4),
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFF0EA5A4).withValues(alpha: 0.12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('分數越高代表需更積極保養。'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<ScanRecord> _applyRange(List<ScanRecord> records) {
    final now = DateTime.now();
    final from = switch (_selected) {
      _RangeFilter.days7 => now.subtract(const Duration(days: 7)),
      _RangeFilter.days30 => now.subtract(const Duration(days: 30)),
      _RangeFilter.all => null,
    };
    if (from == null) return records;
    return records.where((record) => record.createdAt.isAfter(from)).toList();
  }

  double _labelInterval(int count) {
    if (count <= 6) return 1;
    if (count <= 12) return 2;
    return (count / 6).ceilToDouble();
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$mm/$dd';
  }

  int _skinScore(ScanRecord record) {
    final concernsScore = record.concerns.length * 2;
    final skinTypeBonus = switch (record.skinType) {
      '油性肌' => 2,
      '乾性肌' => 2,
      '混合肌' => 1,
      _ => 1,
    };
    return (concernsScore + skinTypeBonus).clamp(1, 10);
  }
}
