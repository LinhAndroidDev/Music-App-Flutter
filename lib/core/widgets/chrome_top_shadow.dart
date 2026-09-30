import 'package:flutter/material.dart';

/// ServiceMusic search mic FAB — circular [Material] shadow only (no rectangular overlay).
class VoiceSearchFab extends StatelessWidget {
  const VoiceSearchFab({
    super.key,
    required this.onTap,
    required this.icon,
  });

  final VoidCallback onTap;
  final Widget icon;

  static const _fabSize = 50.0;

  /// Room for elevation above/sides; bottom edge aligns with [Positioned.bottom].
  static const _shadowOverflowTop = 22.0;
  static const _shadowOverflowSides = 10.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: _shadowOverflowSides,
        top: _shadowOverflowTop,
        right: _shadowOverflowSides,
      ),
      child: Material(
        elevation: 24,
        shadowColor: const Color(0x73000000),
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: _fabSize,
            height: _fabSize,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}

/// White card at full width; shadow layer bleeds horizontally without shrinking margins.
class ChromeRoundedCardShadow extends StatelessWidget {
  const ChromeRoundedCardShadow({
    super.key,
    required this.height,
    required this.borderRadius,
    required this.child,
    this.shadowBleed = 8,
  });

  final double height;
  final double borderRadius;
  final Widget child;
  final double shadowBleed;

  /// Extends the shadow plate above the card (uses [_cardTopInset] dead zone).
  static const shadowExtendTop = 12.0;
  static const shadowExtendBottom = 4.0;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -shadowBleed,
            right: -shadowBleed,
            top: -shadowExtendTop,
            bottom: -shadowExtendBottom,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: const Color(0x01FFFFFF),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x28000000),
                      blurRadius: 14,
                      spreadRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Material(
            elevation: 0,
            shadowColor: Colors.transparent,
            borderRadius: radius,
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
