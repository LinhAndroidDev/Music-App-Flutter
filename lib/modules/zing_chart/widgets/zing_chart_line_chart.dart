import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/song.dart';
import '../utils/chart_date_format.dart';
import 'zing_chart_avatar_metrics.dart';
import 'zing_chart_static_data.dart';

/// ServiceMusic [ZingChartFragment] line chart + [CustomLineChartRenderer] avatar overlay.
class ZingChartLineChart extends StatefulWidget {
  const ZingChartLineChart({
    super.key,
    required this.playlist,
    this.deferInit = true,
  });

  final List<Song> playlist;
  final bool deferInit;

  @override
  State<ZingChartLineChart> createState() => _ZingChartLineChartState();
}

class _ZingChartLineChartState extends State<ZingChartLineChart>
    with SingleTickerProviderStateMixin {
  static const _chartHeight = 250.0;
  /// Insets aligned with fl_chart titles + ServiceMusic extraTop/Bottom (30 / 10).
  static const _horizontalInset = 10.0;
  static const _plotPadding = EdgeInsets.fromLTRB(0, 30, 0, 38);

  /// fl_chart active dot radius (logical px) — must match [FlDotCirclePainter.radius].
  static const _chartDotRadius = 4.0;

  int _activeSeries = 0;
  bool _chartVisible = false;
  Timer? _rotateTimer;
  late AnimationController _transitionController;
  Offset? _transitionFrom;
  Offset? _transitionTo;
  Size? _lastChartSize;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() => setState(() {}));
    if (widget.deferInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _chartVisible = true);
          _startRotateTimer();
        }
      });
    } else {
      _chartVisible = true;
      _startRotateTimer();
    }
  }

  @override
  void dispose() {
    _rotateTimer?.cancel();
    _transitionController.dispose();
    super.dispose();
  }

  void _startRotateTimer() {
    _rotateTimer?.cancel();
    _rotateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _advanceSeries(resetTimer: false);
    });
  }

  void _resetRotateTimer() {
    _rotateTimer?.cancel();
    _rotateTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _advanceSeries(resetTimer: true);
    });
  }

  void _advanceSeries({required bool resetTimer}) {
    final next = (_activeSeries + 1) % 3;
    _setActiveSeries(next);
    if (resetTimer) {
      _startRotateTimer();
    }
  }

  void _setActiveSeries(int index) {
    final size = _lastChartSize;
    if (size != null) {
      final oldPos = _pixelForSeries(_activeSeries, size);
      final newPos = _pixelForSeries(index, size);
      if (oldPos != newPos) {
        _transitionFrom = oldPos;
        _transitionTo = newPos;
        _transitionController.forward(from: 0);
      } else {
        _transitionFrom = null;
        _transitionTo = null;
      }
    }
    setState(() => _activeSeries = index);
  }

  void _onChartTap() {
    _advanceSeries(resetTimer: true);
    _resetRotateTimer();
  }

  Offset _pixelForSeries(int seriesIndex, Size size) {
    final pointIndex = ZingChartStaticData.highlightPointIndex[seriesIndex];
    final y = ZingChartStaticData.yForSeries(seriesIndex, pointIndex);
    return _dataToPixel(pointIndex.toDouble(), y, size);
  }

  Offset _dataToPixel(double x, double y, Size size) {
    final plotW = size.width - _plotPadding.horizontal;
    final plotH = size.height - _plotPadding.vertical;
    final px = _plotPadding.left + (x / ZingChartStaticData.maxX) * plotW;
    final py =
        _plotPadding.top + (1 - (y - ZingChartStaticData.minY) / (ZingChartStaticData.maxY - ZingChartStaticData.minY)) * plotH;
    return Offset(px, py);
  }

  Offset _currentAvatarCenter(Size size) {
    if (_transitionFrom != null &&
        _transitionTo != null &&
        _transitionController.isAnimating) {
      final t = Curves.decelerate.transform(_transitionController.value);
      return Offset.lerp(_transitionFrom!, _transitionTo!, t)!;
    }
    final pointIndex = ZingChartStaticData.highlightPointIndex[_activeSeries];
    final y = ZingChartStaticData.yForSeries(_activeSeries, pointIndex);
    return _dataToPixel(pointIndex.toDouble(), y, size);
  }

  List<LineChartBarData> _lineBars() {
    final allSeries = [
      ZingChartStaticData.series1Y,
      ZingChartStaticData.series2Y,
      ZingChartStaticData.series3Y,
    ];
    return List.generate(3, (seriesIndex) {
      final spots = List.generate(
        12,
        (i) => FlSpot(i.toDouble(), allSeries[seriesIndex][i]),
      );
      final isActive = seriesIndex == _activeSeries;
      return LineChartBarData(
        spots: spots,
        isCurved: false,
        color: ZingChartStaticData.seriesColors[seriesIndex],
        barWidth: 1.5,
        dotData: FlDotData(
          show: isActive,
          getDotPainter: (spot, percent, bar, index) {
            return FlDotCirclePainter(
              radius: _chartDotRadius,
              color: ZingChartStaticData.seriesColors[seriesIndex],
              strokeWidth: 1.6,
              strokeColor: AppColors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_chartVisible) {
      return const SizedBox(height: _chartHeight);
    }

    final hours = ChartDateFormat.last12Hours();

    return SizedBox(
      height: _chartHeight,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
        child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, _chartHeight);
          _lastChartSize = size;
          final avatarAnchor = _currentAvatarCenter(size);
          final badgeOuter = ZingChartAvatarMetrics.outerSize(context);
          final gapTop = ZingChartAvatarMetrics.gapDotTopToCoverBottom(context);
          final lift = ZingChartAvatarMetrics.dotAlignLift(context);
          final left = avatarAnchor.dx - badgeOuter / 2;
          final top = avatarAnchor.dy - lift - _chartDotRadius - gapTop - badgeOuter;

          return GestureDetector(
            onTap: _onChartTap,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: ZingChartStaticData.maxX,
                    minY: ZingChartStaticData.minY,
                    maxY: ZingChartStaticData.maxY,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: AppColors.greyBlur.withOpacity(0.45)),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false, reservedSize: 30),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= hours.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${hours[i]}',
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: _lineBars(),
                  ),
                  duration: Duration.zero,
                ),
                Positioned(
                  left: left.clamp(-12.0, size.width - badgeOuter + 12),
                  top: top.clamp(-badgeOuter, size.height - badgeOuter * 0.35),
                  child: _ChartAvatarBadge(
                    rank: '${_activeSeries + 1}',
                    borderColor: ZingChartStaticData.seriesColors[_activeSeries],
                    thumbnailUrl: widget.playlist.length > _activeSeries
                        ? widget.playlist[_activeSeries].thumbnailUrl
                        : '',
                  ),
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }
}

class _ChartAvatarBadge extends StatelessWidget {
  const _ChartAvatarBadge({
    required this.rank,
    required this.borderColor,
    required this.thumbnailUrl,
  });

  final String rank;
  final Color borderColor;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final outer = ZingChartAvatarMetrics.outerSize(context);
    final border = ZingChartAvatarMetrics.borderWidth(context);
    final radius = ZingChartAvatarMetrics.cornerRadius(context);
    final rankBottom = ZingChartAvatarMetrics.rankBaselineInsetFromBottom(context);

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: borderColor, width: border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius - 2),
                child: thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(imageUrl: thumbnailUrl, fit: BoxFit.cover)
                    : ColoredBox(
                        color: AppColors.greyLight,
                        child: Center(
                          child: AppIcon(
                            AppAssets.icMusic,
                            size: outer * 0.32,
                            color: AppColors.txtHint,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: rankBottom,
            child: _ChartRankLabel(rank: rank),
          ),
        ],
      ),
    );
  }
}

/// ServiceMusic [drawTextLevel]: black fill + light stroke, bottom-left of cover.
class _ChartRankLabel extends StatelessWidget {
  const _ChartRankLabel({required this.rank});

  final String rank;

  @override
  Widget build(BuildContext context) {
    final fontSize = ZingChartAvatarMetrics.rankFontSize(context);
    final stroke = (1.5 / MediaQuery.devicePixelRatioOf(context)).clamp(0.8, 1.5);
    final fillStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      height: 1,
      color: AppColors.black1,
    );
    final strokeStyle = fillStyle.copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.txtGreyBlur,
    );

    final painter = TextPainter(
      text: TextSpan(text: rank, style: fillStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    // ServiceMusic drawTextLevel: x - measureText(level) / 4 from cover left edge.
    final leftShift = painter.width / 4;

    return Transform.translate(
      offset: Offset(-leftShift, 0),
      child: Stack(
        children: [
          Text(rank, style: strokeStyle),
          Text(rank, style: fillStyle),
        ],
      ),
    );
  }
}
