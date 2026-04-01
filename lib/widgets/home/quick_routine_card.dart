import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';

enum BudgetTier { basic, balanced, premium }

class QuickRoutineCard extends StatelessWidget {
  const QuickRoutineCard({
    super.key,
    required this.skinType,
    required this.concerns,
    required this.suggestion,
    required this.selectedBudget,
    required this.onBudgetChanged,
  });

  final String skinType;
  final List<String> concerns;
  final String suggestion;
  final BudgetTier selectedBudget;
  final ValueChanged<BudgetTier> onBudgetChanged;

  @override
  Widget build(BuildContext context) {
    final routine = _buildRoutine(selectedBudget, concerns);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined),
                const SizedBox(width: 8),
                Text('30 秒保養流程', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppTokens.space2),
            Text('膚質：$skinType'),
            const SizedBox(height: 6),
            Text('AI 建議：$suggestion', maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppTokens.space2),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('入門'),
                  selected: selectedBudget == BudgetTier.basic,
                  onSelected: (_) => onBudgetChanged(BudgetTier.basic),
                ),
                ChoiceChip(
                  label: const Text('均衡'),
                  selected: selectedBudget == BudgetTier.balanced,
                  onSelected: (_) => onBudgetChanged(BudgetTier.balanced),
                ),
                ChoiceChip(
                  label: const Text('進階'),
                  selected: selectedBudget == BudgetTier.premium,
                  onSelected: (_) => onBudgetChanged(BudgetTier.premium),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...routine.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $e'),
                )),
          ],
        ),
      ),
    );
  }

  List<String> _buildRoutine(BudgetTier tier, List<String> concerns) {
    final hasAcne = concerns.contains('痘痘');
    final hasDry = concerns.contains('乾燥') || concerns.contains('脫皮');
    final hasDark = concerns.contains('黑眼圈');

    switch (tier) {
      case BudgetTier.basic:
        return [
          '早：溫和清潔 -> 保濕 -> 防曬',
          '晚：清潔 -> 保濕修護',
          if (hasAcne) '局部抗痘產品，每晚 1 次',
          if (hasDry) '晚間加強鎖水乳霜',
        ];
      case BudgetTier.balanced:
        return [
          '早：清潔 -> 精華 -> 保濕 -> 防曬',
          '晚：清潔 -> 功能精華 -> 修護乳',
          if (hasDark) '眼周咖啡因產品，晚間使用',
          if (hasAcne) '每週 2 次角質代謝',
        ];
      case BudgetTier.premium:
        return [
          '早：清潔 -> 抗氧化精華 -> 保濕 -> 防曬',
          '晚：清潔 -> 修護精華 -> 乳霜 -> 局部加強',
          if (hasAcne) '抗痘+舒緩雙精華輪替',
          if (hasDry) '睡前修護面膜每週 2 次',
          if (hasDark) '眼周精華早晚分層',
        ];
    }
  }
}
