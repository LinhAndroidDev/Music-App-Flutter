import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import 'splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: _SplashBody(onEntranceComplete: controller.onEntranceComplete),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody({required this.onEntranceComplete});

  final VoidCallback onEntranceComplete;

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody> with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final AnimationController _markCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _subtitleCtrl;

  late final Animation<double> _glowOpacity;
  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleOffset;
  late final Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();
    const decelerate = Curves.decelerate;

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _markCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _subtitleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _glowOpacity = CurvedAnimation(parent: _glowCtrl, curve: decelerate);
    _markOpacity = CurvedAnimation(parent: _markCtrl, curve: decelerate);
    _markScale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _markCtrl, curve: decelerate),
    );
    _titleOpacity = CurvedAnimation(parent: _titleCtrl, curve: decelerate);
    _titleOffset = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(parent: _titleCtrl, curve: decelerate),
    );
    _subtitleOpacity = CurvedAnimation(parent: _subtitleCtrl, curve: decelerate);

    _playEntrance();
  }

  Future<void> _playEntrance() async {
    _glowCtrl.forward();
    _markCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    _titleCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    _subtitleCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    widget.onEntranceComplete();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _markCtrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Align(
      alignment: const Alignment(0, -0.16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 280,
                height: 280,
                child: AnimatedBuilder(
                  animation: _glowOpacity,
                  builder: (context, child) => Opacity(
                    opacity: _glowOpacity.value,
                    child: child,
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.95,
                        colors: [
                          Color(0xA0785CFF),
                          Color(0x80673AB7),
                          Color(0x00100C18),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: Listenable.merge([_markOpacity, _markScale]),
                builder: (context, child) => Opacity(
                  opacity: _markOpacity.value,
                  child: Transform.scale(
                    scale: _markScale.value,
                    child: child,
                  ),
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.splashMark,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: AppColors.splashMarkStroke,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const AppIcon(
                    AppAssets.icMusic,
                    size: 60,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: Listenable.merge([_titleOpacity, _titleOffset]),
            builder: (context, child) => Opacity(
              opacity: _titleOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _titleOffset.value),
                child: child,
              ),
            ),
            child: Text(
              l10n.app_name,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 28,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.56,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _subtitleOpacity,
            builder: (context, child) => Opacity(
              opacity: _subtitleOpacity.value,
              child: child,
            ),
            child: Text(
              l10n.splash_tagline,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                letterSpacing: 0.56,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
