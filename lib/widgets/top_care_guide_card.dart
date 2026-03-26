import 'package:flutter/material.dart';

class TopCareGuideCard extends StatelessWidget {
  const TopCareGuideCard({
    super.key,
    required this.skinType,
    required this.suggestion,
  });

  final String skinType;
  final String suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFEDE8FF), Color(0xFFE7F1FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A7B80E8),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.spa_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '基礎早晚保養步驟',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: const [
                      _GuideChip(label: '早上：清潔'),
                      _GuideChip(label: '早上：保濕'),
                      _GuideChip(label: '早上：防曬'),
                      _GuideChip(label: '晚上：清潔'),
                      _GuideChip(label: '晚上：保濕'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('膚質：$skinType'),
                  const SizedBox(height: 6),
                  Text(
                    suggestion,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideChip extends StatelessWidget {
  const _GuideChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD7D8F7)),
      ),
      child: Text(label),
    );
  }
}
