import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/lyrics/timed_lyric_line.dart';

/// ServiceMusic [item_lyric_line.xml] + [LineLyricsAdapter.VH].
class LyricLineTile extends StatelessWidget {
  const LyricLineTile({
    super.key,
    required this.line,
    required this.selected,
    required this.onTap,
  });

  static const transitionDuration = Duration(milliseconds: 420);
  static const _softCurve = Curves.easeOutCubic;

  static const idleScale = 0.94;
  static const highlightScale = 1.03;

  final TimedLyricLine line;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final targetColor = selected ? AppColors.lyricLineActive : AppColors.textWhite;
    final targetScale = selected ? highlightScale : idleScale;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: transitionDuration,
                  curve: _softCurve,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.lyricHighlightScrim,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              AnimatedScale(
                scale: targetScale,
                alignment: Alignment.centerLeft,
                duration: transitionDuration,
                curve: _softCurve,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: AnimatedDefaultTextStyle(
                    duration: transitionDuration,
                    curve: _softCurve,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                      color: targetColor,
                      shadows: selected
                          ? const [
                              Shadow(
                                blurRadius: 4,
                                offset: Offset(0, 1),
                                color: Color(0x3C282828),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      line.text,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
