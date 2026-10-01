/// Home banner carousel: [PageView] with [viewportFraction] so adjacent banners peek.
class BannerCarouselMetrics {
  BannerCarouselMetrics._(this.screenWidth);

  /// Focused page width vs screen (see discover banner [PageView]).
  static const viewportFraction = 0.75;

  static const viewportHeight = 330.0;
  static const itemSpacing = 8.0;

  final double screenWidth;

  /// Inset from screen edge when the current page is snapped (each side).
  late final double sideInset = screenWidth * (1 - viewportFraction) / 2;

  /// Usable width inside one page slot (minus inner spacing between cards).
  late final double bannerWidth = screenWidth * viewportFraction - itemSpacing;

  late final double sidePeekWidth = sideInset;

  double get cardHeight => viewportHeight;

  factory BannerCarouselMetrics.fromWidth(double screenWidth) {
    return BannerCarouselMetrics._(screenWidth);
  }
}
