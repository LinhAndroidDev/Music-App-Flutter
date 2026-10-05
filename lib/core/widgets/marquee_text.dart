import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Single-line text that scrolls in a seamless loop when it doesn't fit, with faded edges
/// (ServiceMusic [LoopingMarqueeText]). Text that fits is drawn as a plain [Text].
///
/// Loop: wait [startPause], scroll one text width + [gap] at [speed], hold [loopPause], repeat.
/// The right edge is always faded while scrolling; the left edge only while the text is passing it.
/// Rebuilding with the same text/style/width keeps the current cycle running.
class MarqueeText extends StatefulWidget {
  const MarqueeText(
    this.text, {
    super.key,
    this.style,
    this.gap = 15,
    this.fadeWidth = 16,
    this.speed = 40,
    this.startPause = const Duration(seconds: 1),
    this.loopPause = const Duration(seconds: 2),
  });

  final String text;
  final TextStyle? style;

  /// Space between the end of the text and its looping copy (logical px).
  final double gap;

  /// Width of each faded edge (logical px), capped at a quarter of the available width.
  final double fadeWidth;

  /// Scroll speed in logical px per second.
  final double speed;

  final Duration startPause;
  final Duration loopPause;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  TextPainter? _painter;
  Object? _painterKey;

  /// Identifies the current scroll cycle; bumped to cancel a running loop.
  int _generation = 0;
  Object? _runKey;

  @override
  void initState() {
    super.initState();
    // Created eagerly: a lazy controller first touched in dispose() would look up TickerMode on a
    // deactivated element (text that always fit never starts it).
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _generation++;
    _controller.dispose();
    _painter?.dispose();
    super.dispose();
  }

  TextPainter _layoutText(TextStyle style, TextScaler scaler, TextDirection direction) {
    final key = (widget.text, style, scaler, direction);
    if (_painter != null && _painterKey == key) return _painter!;
    _painter?.dispose();
    _painterKey = key;
    return _painter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
  }

  /// (Re)starts the loop only when what's being scrolled actually changed.
  void _syncRun({required double width, required double textWidth}) {
    final key = (widget.text, width, textWidth, widget.gap, widget.speed);
    if (_runKey == key) return;
    _runKey = key;
    final generation = ++_generation;
    _controller
      ..stop()
      ..value = 0
      ..duration = Duration(
        milliseconds: math.max(1, ((textWidth + widget.gap) / widget.speed * 1000).round()),
      );
    unawaited(_loop(generation));
  }

  void _stopRun() {
    if (_runKey == null) return;
    _runKey = null;
    _generation++;
    _controller
      ..stop()
      ..value = 0;
  }

  Future<void> _loop(int generation) async {
    bool alive() => mounted && generation == _generation;

    await Future<void>.delayed(widget.startPause);
    while (alive()) {
      try {
        // Offset 0 and offset (textWidth + gap) look identical, so restarting from 0 is seamless.
        await _controller.forward(from: 0).orCancel;
      } on TickerCanceled {
        return;
      }
      if (!alive()) return;
      await Future<void>.delayed(widget.loopPause);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final painter = _layoutText(
      style,
      MediaQuery.textScalerOf(context),
      Directionality.of(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (!width.isFinite || painter.width <= width) {
          _stopRun();
          return Text(
            widget.text,
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
          );
        }

        _syncRun(width: width, textWidth: painter.width);
        return Semantics(
          label: widget.text,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(width, painter.height),
              painter: _MarqueePainter(
                text: painter,
                animation: _controller,
                gap: widget.gap,
                fadeWidth: widget.fadeWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MarqueePainter extends CustomPainter {
  _MarqueePainter({
    required this.text,
    required this.animation,
    required this.gap,
    required this.fadeWidth,
  }) : super(repaint: animation);

  final TextPainter text;
  final AnimationController animation;
  final double gap;
  final double fadeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final textWidth = text.width;
    final offset = animation.value * (textWidth + gap);
    final fadeLeft = animation.isAnimating && offset < textWidth;
    final edge = math.min(fadeWidth, size.width / 4) / size.width;
    final y = (size.height - text.height) / 2;

    canvas
      ..clipRect(rect)
      ..saveLayer(rect, Paint());
    text
      ..paint(canvas, Offset(-offset, y))
      ..paint(canvas, Offset(-offset + textWidth + gap, y));
    canvas
      ..drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = LinearGradient(
            colors: [
              fadeLeft ? Colors.transparent : Colors.black,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0, edge, 1 - edge, 1],
          ).createShader(rect),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_MarqueePainter old) =>
      old.text != text || old.animation != animation || old.gap != gap || old.fadeWidth != fadeWidth;
}
