import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/home_advertisement.dart';
import 'banner_carousel_metrics.dart';
import 'home_ad_banner_item.dart' show HomeAdBannerCard;

/// ServiceMusic: [RecyclerView] + [PagerSnapHelper] → [PageView] + [PageScrollPhysics].
class HomeAdBannerCarousel extends StatefulWidget {
  const HomeAdBannerCarousel({super.key, required this.ads});

  final List<HomeAdvertisement> ads;

  @override
  State<HomeAdBannerCarousel> createState() => _HomeAdBannerCarouselState();
}

class _HomeAdBannerCarouselState extends State<HomeAdBannerCarousel> {
  static const _autoScrollMs = 5000;
  static const _infiniteMultiplier = 1000;

  PageController? _pageController;
  Timer? _timer;
  double? _viewportFraction;
  int _realIndex = 0;
  bool _userDragging = false;
  bool _pendingInitialScroll = false;

  @override
  void didUpdateWidget(HomeAdBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ads.length != widget.ads.length ||
        !_sameAdIds(oldWidget.ads, widget.ads)) {
      _disposePageController();
    }
  }

  bool _sameAdIds(List<HomeAdvertisement> a, List<HomeAdvertisement> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _ensurePageController(BannerCarouselMetrics metrics) {
    if (widget.ads.isEmpty) return;
    final count = widget.ads.length;
    final fraction = count > 1 ? metrics.viewportFraction : 1.0;
    if (_pageController != null && _viewportFraction == fraction) {
      return;
    }
    _disposePageController();
    final start = count > 1 ? count * (_infiniteMultiplier ~/ 2) : 0;
    _realIndex = 0;
    _viewportFraction = fraction;
    _pageController = PageController(
      initialPage: start,
      viewportFraction: fraction,
    );
    _pendingInitialScroll = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialScrollPosition();
    });
    _startAutoScroll();
  }

  void _applyInitialScrollPosition() {
    if (!_pendingInitialScroll || !mounted) return;
    final controller = _pageController;
    if (controller == null || widget.ads.length <= 1) {
      _pendingInitialScroll = false;
      return;
    }
    if (!controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyInitialScrollPosition();
      });
      return;
    }
    final target = controller.initialPage;
    final current = controller.page;
    if (current == null || (current - target).abs() > 0.001) {
      controller.jumpToPage(target);
    }
    _pendingInitialScroll = false;
    setState(() {});
  }

  void _disposePageController() {
    _timer?.cancel();
    _pageController?.dispose();
    _pageController = null;
    _viewportFraction = null;
    _pendingInitialScroll = false;
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.ads.length <= 1 || _userDragging) return;
    _timer = Timer.periodic(const Duration(milliseconds: _autoScrollMs), (_) {
      _advancePage();
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _advancePage() async {
    if (!mounted ||
        _userDragging ||
        _pageController == null ||
        !_pageController!.hasClients ||
        widget.ads.length <= 1) {
      return;
    }
    await _pageController!.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (widget.ads.length <= 1) return false;

    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _userDragging = true;
      _stopAutoScroll();
    } else if (notification is ScrollEndNotification) {
      _userDragging = false;
      _repositionInfiniteIfNeeded();
      _startAutoScroll();
    }
    return false;
  }

  void _repositionInfiniteIfNeeded() {
    final controller = _pageController;
    final count = widget.ads.length;
    if (controller == null ||
        !controller.hasClients ||
        count <= 1) {
      return;
    }
    final snapped = controller.page?.round() ?? controller.initialPage;
    final total = count * _infiniteMultiplier;
    final threshold = count * 2;
    final middleOffset = count * (_infiniteMultiplier ~/ 2);
    int? newPage;
    if (snapped < threshold) {
      newPage = snapped + middleOffset;
    } else if (snapped > total - threshold) {
      newPage = snapped - middleOffset;
    }
    if (newPage != null) {
      controller.jumpToPage(newPage);
    }
  }

  int _toRealIndex(int page) {
    final count = widget.ads.length;
    if (count == 0) return 0;
    return ((page % count) + count) % count;
  }

  ({double scale, double opacity}) _depthForPage(
    PageController controller,
    int index,
  ) {
    final page = controller.position.haveDimensions
        ? (controller.page ?? controller.initialPage.toDouble())
        : controller.initialPage.toDouble();
    final delta = (page - index).abs();
    if (delta < 0.001) {
      return (scale: 1.0, opacity: 1.0);
    }
    final distance = delta.clamp(0.0, 1.0);
    final scaleReduction = (distance * 0.2).clamp(0.0, 0.2);
    final alphaReduction = (distance * 0.45).clamp(0.0, 0.5);
    return (scale: 1 - scaleReduction, opacity: 1 - alphaReduction);
  }

  @override
  void dispose() {
    _disposePageController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = widget.ads;
    if (ads.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final metrics = BannerCarouselMetrics.fromWidth(screenWidth);

    if (ads.length == 1) {
      final ad = ads.first;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BannerCarouselMetrics.horizontalScreenInset,
            ),
            child: SizedBox(
              height: BannerCarouselMetrics.viewportHeight,
              width: metrics.bannerWidth,
              child: HomeAdBannerCard(
                imageUrl: ad.image,
                update: ad.update,
                detail: ad.detail,
              ),
            ),
          ),
        ],
      );
    }

    _ensurePageController(metrics);

    final controller = _pageController;
    if (controller == null) return const SizedBox.shrink();

    final itemCount = ads.length * _infiniteMultiplier;

    return Column(
      children: [
        SizedBox(
          height: BannerCarouselMetrics.viewportHeight,
          width: screenWidth,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: PageView.builder(
              controller: controller,
              clipBehavior: Clip.none,
              padEnds: true,
              physics: const PageScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: itemCount,
              onPageChanged: (page) {
                setState(() => _realIndex = _toRealIndex(page));
              },
              itemBuilder: (context, index) {
                final ad = ads[_toRealIndex(index)];
                return SizedBox(
                  height: BannerCarouselMetrics.viewportHeight,
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      final depth = _depthForPage(controller, index);
                      return Opacity(
                        opacity: depth.opacity,
                        child: Transform.scale(
                          scale: depth.scale,
                          alignment: Alignment.center,
                          child: child,
                        ),
                      );
                    },
                    child: HomeAdBannerCard(
                      imageUrl: ad.image,
                      update: ad.update,
                      detail: ad.detail,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        _BannerDots(count: ads.length, index: _realIndex),
      ],
    );
  }
}

class _BannerDots extends StatelessWidget {
  const _BannerDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == index;
        return Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.blue : AppColors.grey1,
          ),
        );
      }),
    );
  }
}
