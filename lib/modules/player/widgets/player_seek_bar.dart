import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Thin seek bar matching ServiceMusic `seekbar_progress.xml` (2dp track, #474747 / white).
class PlayerSeekBar extends StatelessWidget {
  const PlayerSeekBar({
    super.key,
    required this.value,
    this.enabled = true,
    this.onDragStart,
    this.onChanged,
    this.onDragEnd,
  });

  static const _trackHeight = 2.0;
  static const _trackBg = Color(0xFF474747);
  static const _thumbRadius = 6.0;
  static const _touchHeight = 28.0;

  final double value;
  final bool enabled;
  final VoidCallback? onDragStart;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onDragEnd;

  double _fractionFromLocalDx(double dx, double width) {
    if (width <= 0) return 0;
    return (dx / width).clamp(0.0, 1.0);
  }

  void _handleDrag(BuildContext context, Offset globalPosition) {
    if (!enabled || onChanged == null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPosition);
    onChanged!(_fractionFromLocalDx(local.dx, box.size.width));
  }

  @override
  Widget build(BuildContext context) {
    final fraction = value.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final progressWidth = width * fraction;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: enabled
              ? (d) {
                  onDragStart?.call();
                  _handleDrag(context, d.globalPosition);
                }
              : null,
          onHorizontalDragUpdate: enabled
              ? (d) => _handleDrag(context, d.globalPosition)
              : null,
          onHorizontalDragEnd: enabled ? (_) => onDragEnd?.call() : null,
          onTapDown: enabled
              ? (d) {
                  onDragStart?.call();
                  _handleDrag(context, d.globalPosition);
                }
              : null,
          onTapUp: enabled ? (_) => onDragEnd?.call() : null,
          child: SizedBox(
            height: _touchHeight,
            width: width,
            child: Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: _trackHeight,
                  width: width,
                  decoration: BoxDecoration(
                    color: _trackBg,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                Container(
                  height: _trackHeight,
                  width: progressWidth.clamp(0.0, width),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                Positioned(
                  left: (progressWidth - _thumbRadius).clamp(0.0, width - _thumbRadius * 2),
                  top: (_touchHeight - _thumbRadius * 2) / 2,
                  child: Container(
                    width: _thumbRadius * 2,
                    height: _thumbRadius * 2,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
