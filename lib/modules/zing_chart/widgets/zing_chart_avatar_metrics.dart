import 'package:flutter/widgets.dart';

/// Sizes from ServiceMusic [CustomLineChartRenderer.drawAvatarAt] (canvas pixels).
abstract final class ZingChartAvatarMetrics {
  ZingChartAvatarMetrics._();

  static const _androidImagePx = 80.0;
  static const _androidBorderPx = 4.0;
  /// Center of dot → bottom of cover ([drawAvatarAt]).
  static const _androidGapCenterToCoverBottomPx = 13.0;
  static const _androidDotRadiusPx = 4.0;
  /// fl_chart Y vs overlay mapping fine-tune.
  static const _androidDotAlignLiftPx = 12.0;
  static const _androidRankTextPx = 49.0;
  static const _androidCornerPx = 8.0;
  static const _androidRankBaselineFromBottomPx = 5.0;

  static double _toLogical(double androidPx, double dpr) => androidPx / dpr;

  static double imageSize(BuildContext context) =>
      _toLogical(_androidImagePx, MediaQuery.devicePixelRatioOf(context));

  static double borderWidth(BuildContext context) =>
      _toLogical(_androidBorderPx, MediaQuery.devicePixelRatioOf(context));

  static double outerSize(BuildContext context) =>
      imageSize(context) + borderWidth(context) * 2;

  /// Gap from dot top to cover bottom (13px center gap − 4px radius).
  static double gapDotTopToCoverBottom(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final centerToBottom = _toLogical(_androidGapCenterToCoverBottomPx, dpr);
    final dotR = _toLogical(_androidDotRadiusPx, dpr);
    return centerToBottom - dotR;
  }

  static double activeDotRadius(BuildContext context) =>
      _toLogical(_androidDotRadiusPx, MediaQuery.devicePixelRatioOf(context));

  static double dotAlignLift(BuildContext context) =>
      _toLogical(_androidDotAlignLiftPx, MediaQuery.devicePixelRatioOf(context));

  static double rankFontSize(BuildContext context) =>
      _toLogical(_androidRankTextPx, MediaQuery.devicePixelRatioOf(context));

  static double cornerRadius(BuildContext context) =>
      _toLogical(_androidCornerPx, MediaQuery.devicePixelRatioOf(context));

  static double rankBaselineInsetFromBottom(BuildContext context) =>
      _toLogical(_androidRankBaselineFromBottomPx, MediaQuery.devicePixelRatioOf(context));
}
