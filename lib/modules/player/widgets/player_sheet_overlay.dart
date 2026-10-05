import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigate.dart';

/// Full-screen player enter/exit — slide up from bottom (ServiceMusic [FragmentMusic] bottom sheet).
class PlayerSheetOverlay extends StatefulWidget {
  const PlayerSheetOverlay({
    super.key,
    required this.isOpen,
    required this.child,
  });

  final bool isOpen;
  final Widget child;

  static const _duration = Duration(milliseconds: 320);

  @override
  State<PlayerSheetOverlay> createState() => _PlayerSheetOverlayState();
}

class _PlayerSheetOverlayState extends State<PlayerSheetOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _scrim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: PlayerSheetOverlay._duration);
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curve);
    _scrim = Tween<double>(begin: 0, end: 0.45).animate(curve);
    // Rebuild once the close animation ends so [build] drops the sheet subtree — don't rely on
    // the parent happening to rebuild.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) setState(() {});
    });
    if (widget.isOpen) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PlayerSheetOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _controller.forward(from: 0);
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _interactive => widget.isOpen || _controller.isAnimating;

  @override
  Widget build(BuildContext context) {
    if (!_interactive && _controller.value == 0) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FadeTransition(
          opacity: _scrim,
          child: IgnorePointer(
            ignoring: !_interactive,
            child: GestureDetector(
              onTap: AppNavigate.closePlayer,
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Colors.black),
            ),
          ),
        ),
        SlideTransition(
          position: _slide,
          child: widget.child,
        ),
      ],
    );
  }
}
