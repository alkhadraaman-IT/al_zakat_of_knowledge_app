import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/incoming_message.dart';
import '../../domain/entities/notification_target.dart';
import 'notification_type_style.dart';

/// يغلّف التطبيق كله (MaterialApp.builder) ويعرض شريط إشعار مرئي أعلى الشاشة
/// عند وصول رسالة والتطبيق مفتوح. يُغلق تلقائياً بعد 4 ثوانٍ أو بالسحب للأعلى،
/// والضغط عليه يفتح الوجهة.
class InAppNotificationHost extends StatefulWidget {
  final Widget child;
  final Stream<IncomingMessage> banners;
  final void Function(NotificationTarget target) onOpen;

  const InAppNotificationHost({
    super.key,
    required this.child,
    required this.banners,
    required this.onOpen,
  });

  @override
  State<InAppNotificationHost> createState() => _InAppNotificationHostState();
}

class _InAppNotificationHostState extends State<InAppNotificationHost> {
  StreamSubscription<IncomingMessage>? _sub;
  final _queue = <IncomingMessage>[];
  IncomingMessage? _current;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sub = widget.banners.listen((m) {
      _queue.add(m);
      if (_current == null) _next();
    });
  }

  void _next() {
    if (!mounted) return;
    if (_queue.isEmpty) {
      setState(() => _current = null);
      return;
    }
    setState(() => _current = _queue.removeAt(0));
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _current = null);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && _current == null) _next();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _current;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (m != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(m.id),
                  tween: Tween(begin: -1, end: 0),
                  duration: const Duration(milliseconds: 250),
                  builder: (context, v, child) =>
                      FractionalTranslation(translation: Offset(0, v), child: child),
                  child: _Banner(
                    message: m,
                    onTap: () {
                      _dismiss();
                      final t = m.target;
                      if (t != null) widget.onOpen(t);
                    },
                    onSwipeUp: _dismiss,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final IncomingMessage message;
  final VoidCallback onTap;
  final VoidCallback onSwipeUp;

  const _Banner({required this.message, required this.onTap, required this.onSwipeUp});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = message.type.style;
    final accent = style.isAlert ? cs.error : cs.primary;

    return GestureDetector(
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -100) onSwipeUp();
      },
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHigh,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(style.icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
