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
                      const SizedBox(height: 8),
                      _ScoreMethodCard(sample: filtered.last),
                      const SizedBox(height: 8),
                      const _ScoreRangeAdviceCard(),
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

class _ScoreMethodCard extends StatelessWidget {
  const _ScoreMethodCard({required this.sample});

  final ScanRecord sample;

  @override
  Widget build(BuildContext context) {
    final concernsScore = sample.concerns.length * 2;
    final skinTypeBonus = switch (sample.skinType) {
      '油性肌' => 2,
      '乾性肌' => 2,
      '混合肌' => 1,
      _ => 1,
    };
    final total = (concernsScore + skinTypeBonus).clamp(1, 10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '膚況分數計算方式',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          const Text('公式：分數 = (問題數量 × 2) + 膚質加權，最後限制在 1~10。'),
          const SizedBox(height: 4),
          const Text('膚質加權：油性肌 +2、乾性肌 +2、混合肌 +1、其他 +1。'),
          const SizedBox(height: 8),
          Text(
            '範例：本次問題 ${sample.concerns.length} 個 -> ${sample.concerns.length} × 2 = $concernsScore；'
            '膚質 ${sample.skinType} 加權 = $skinTypeBonus；最終分數 = $total。',
          ),
        ],
      ),
    );
  }
}

class _ScoreRangeAdviceCard extends StatelessWidget {
  const _ScoreRangeAdviceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3E2B8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('分數區間對應建議'),
          SizedBox(height: 6),
          Text('1-3（穩定）：維持清潔、保濕、防曬三步驟即可。'),
          SizedBox(height: 4),
          Text('4-6（需加強）：增加 1 項針對性精華，並觀察 1-2 週。'),
          SizedBox(height: 4),
          Text('7-10（高風險）：先簡化保養流程，優先修護與降低刺激。'),
        ],
      ),
    );
  }
}
