import '../../../core/theme/app_colors.dart';

/// Sample line data from ServiceMusic [ZingChartFragment.getOrBuildChartData].
abstract final class ZingChartStaticData {
  static const series1Y = <double>[
    100, 89, 95, 92, 96, 90, 95, 95, 88, 90, 85, 84,
  ];
  static const series2Y = <double>[
    63, 55, 46, 54, 44, 39, 40, 58, 54, 46, 54, 54,
  ];
  static const series3Y = <double>[
    10, 20, 15, 16, 5, 10, 27, 30, 30, 22, 19, 28,
  ];

  static const highlightPointIndex = [4, 5, 8];

  static const seriesColors = [
    AppColors.blue1,
    AppColors.green3,
    AppColors.brown,
  ];

  static const minY = 0.0;
  static const maxY = 100.0;
  static const maxX = 11.0;

  static double yForSeries(int seriesIndex, int pointIndex) {
    return switch (seriesIndex) {
      0 => series1Y[pointIndex],
      1 => series2Y[pointIndex],
      _ => series3Y[pointIndex],
    };
  }
}
