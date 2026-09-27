/// Home banner carousel: screen inset + peek of adjacent pages via [PageView].
class BannerCarouselMetrics {
  BannerCarouselMetrics._(this.screenWidth);

  /// Distance from screen left/right to the focused banner when snapped.
  static const horizontalScreenInset = 30.0;

  static const viewportHeight = 330.0;
  static const verticalMargin = 0.0;

  final double screenWidth;

  /// Width of the focused banner (screen width minus both insets).
  late final double bannerWidth =
      screenWidth - horizontalScreenInset * 2;

  /// With [PageView], adjacent banners peek by one inset on each side.
  late final double sidePeekWidth = horizontalScreenInset;

  late final double viewportFraction = bannerWidth / screenWidth;

  double get cardHeight => viewportHeight - verticalMargin * 2;

  factory BannerCarouselMetrics.fromWidth(double screenWidth) {
    return BannerCarouselMetrics._(screenWidth);
  }
}
