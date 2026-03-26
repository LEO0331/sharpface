import 'dart:async';

import 'package:flutter/material.dart';

class AdMarqueeBanner extends StatefulWidget {
  const AdMarqueeBanner({
    super.key,
    required this.hasAcneConcern,
    required this.adMessages,
  });

  final bool hasAcneConcern;
  final List<String> adMessages;

  @override
  State<AdMarqueeBanner> createState() => _AdMarqueeBannerState();
}

class _AdMarqueeBannerState extends State<AdMarqueeBanner> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTicker();
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
    super.dispose();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.adMessages.isEmpty) return;
      setState(() {
        _index = (_index + 1) % widget.adMessages.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAd = widget.adMessages.isEmpty ? '暫無廣告內容' : widget.adMessages[_index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.hasAcneConcern ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: TweenAnimationBuilder<Offset>(
              tween: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(value.dx * 20, 0),
                  child: child,
                );
              },
              child: Text(
                currentAd,
                key: ValueKey<String>(currentAd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
