import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';

class AdMarqueeBanner extends StatefulWidget {
  const AdMarqueeBanner({
    super.key,
    required this.hasAcneConcern,
    required this.adMessages,
    required this.onAdImpression,
    required this.onAdClick,
  });

  final bool hasAcneConcern;
  final List<String> adMessages;
  final ValueChanged<String> onAdImpression;
  final ValueChanged<String> onAdClick;

  @override
  State<AdMarqueeBanner> createState() => _AdMarqueeBannerState();
}

class _AdMarqueeBannerState extends State<AdMarqueeBanner> {
  int _index = 0;
  Timer? _timer;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
    _startTicker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firstAd = widget.adMessages.isEmpty ? '暫無廣告內容' : widget.adMessages.first;
      widget.onAdImpression(firstAd);
    });
  }

  @override
  void didUpdateWidget(covariant AdMarqueeBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adMessages != widget.adMessages) {
      _index = 0;
      _startTicker();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.adMessages.isEmpty) return;
      setState(() {
        _index = (_index + 1) % widget.adMessages.length;
      });
      widget.onAdImpression(widget.adMessages[_index]);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _index,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ads = widget.adMessages.isEmpty ? const ['暫無廣告內容'] : widget.adMessages;
    final gradientColors = widget.hasAcneConcern
        ? const [Color(0xFFFFF3F0), Color(0xFFFFE1DE)]
        : const [Color(0xFFEEE9FF), Color(0xFFE1EEFF)];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppTokens.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_outlined),
              const SizedBox(width: 8),
              Text(
                '精準推薦',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 84,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() => _index = value);
                if (value < ads.length) {
                  widget.onAdImpression(ads[value]);
                }
              },
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final ad = ads[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => widget.onAdClick(ad),
                    child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      border: Border.all(color: const Color(0xFFD9DCF8)),
                    ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAE7FF),
                                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                              ),
                              child: const Icon(Icons.auto_awesome_outlined, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ad,
                                key: ValueKey<String>(ad),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              ads.length.clamp(1, 5),
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: _index == i ? 16 : 6,
                decoration: BoxDecoration(
                  color: _index == i ? const Color(0xFF626BDA) : const Color(0xFFBFC8EE),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
