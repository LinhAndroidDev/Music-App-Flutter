import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../playlist_shared_element.dart';
import 'playlist_hero_widgets.dart';

/// Collapsing playlist header: cover + title + meta shrink into one row with back/menu.
class ResizableHeaderScroll extends StatelessWidget {
  const ResizableHeaderScroll({
    super.key,
    required this.playlistId,
    required this.onBack,
    required this.onMenu,
    required this.coverUrl,
    required this.title,
    required this.meta,
    required this.slivers,
  });

  final String playlistId;
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final String coverUrl;
  final String title;
  final String meta;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _ResizablePlaylistHeaderDelegate(
            playlistId: playlistId,
            onBack: onBack,
            onMenu: onMenu,
            coverUrl: coverUrl,
            title: title,
            meta: meta,
          ),
        ),
        ...slivers,
      ],
    );
  }
}

class _ResizablePlaylistHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ResizablePlaylistHeaderDelegate({
    required this.playlistId,
    required this.onBack,
    required this.onMenu,
    required this.coverUrl,
    required this.title,
    required this.meta,
  });

  final String playlistId;
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final String coverUrl;
  final String title;
  final String meta;

  static const _expandedCover = 180.0;
  static const _collapsedCover = 40.0;
  static const _backSize = 25.0;
  static const _paddingLeft = 20.0;
  static const _paddingRight = 10.0;
  static const _gapAfterBack = 12.0;
  static const _gapAfterCover = 12.0;
  static const _textBlockHeight = 36.0;

  static const _expandedTopInset = 12.0;
  static const _contentExpandedHeight = 16 + _expandedCover + 10 + 24 + 3 + 16 + 16;

  static const _headerMaxExtent =
      _expandedTopInset + _backSize + 16 + _contentExpandedHeight;
  static const _headerMinExtent = 64.0;

  @override
  double get maxExtent => _headerMaxExtent;

  @override
  double get minExtent => _headerMinExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 0.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final coverSize = lerpDouble(_expandedCover, _collapsedCover, t)!;
    final titleFontSize = lerpDouble(20, 16, t)!;
    final coverElevation = lerpDouble(6, 0, t)!;

    return ColoredBox(
      color: AppColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headerW = constraints.maxWidth;
          final headerH = constraints.maxHeight;

          final backTop = lerpDouble(_expandedTopInset, (headerH - _backSize) / 2, t)!;
          final menuTop = backTop;

          final coverLeftExpanded = (headerW - coverSize) / 2;
          final coverLeftCollapsed = _paddingLeft + _backSize + _gapAfterBack;
          final coverLeft = lerpDouble(coverLeftExpanded, coverLeftCollapsed, t)!;

          final coverTopExpanded = _expandedTopInset + _backSize + 16;
          final coverTop = lerpDouble(coverTopExpanded, (headerH - coverSize) / 2, t)!;

          // Keep title/meta tied to the cover each frame (avoids desync / jumps).
          final textTopBelowCover = coverTop + coverSize + 10;
          final textTopBesideCover = coverTop + (coverSize - _textBlockHeight) / 2;
          final textTop = lerpDouble(textTopBelowCover, textTopBesideCover, t)!;

          final textLeftExpanded = _paddingLeft;
          final textLeftCollapsed = coverLeft + coverSize + _gapAfterCover;
          final textLeft = lerpDouble(textLeftExpanded, textLeftCollapsed, t)!;
          const textRightCollapsed = _paddingRight + _backSize + 8;
          final textRight = lerpDouble(_paddingLeft, textRightCollapsed, t)!;

          final textAlignment = Alignment.lerp(Alignment.topCenter, Alignment.centerLeft, t)!;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: _paddingLeft,
                top: backTop,
                child: InkWell(
                  onTap: onBack,
                  child: const AppIcon(
                    AppAssets.icBackThin,
                    size: _backSize,
                    color: AppColors.black,
                  ),
                ),
              ),
              Positioned(
                right: _paddingRight,
                top: menuTop,
                child: InkWell(
                  onTap: onMenu,
                  child: const AppIcon(
                    AppAssets.icMenu,
                    size: _backSize,
                    color: AppColors.black,
                  ),
                ),
              ),
              Positioned(
                left: coverLeft,
                top: coverTop,
                child: PlaylistHeroCover(
                  tag: PlaylistSharedElement.coverTag(playlistId),
                  coverUrl: coverUrl,
                  size: coverSize,
                  elevation: coverElevation,
                ),
              ),
              Positioned(
                left: textLeft,
                top: textTop,
                right: textRight,
                child: Align(
                  alignment: textAlignment,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlaylistHeroTitle(
                        tag: PlaylistSharedElement.titleTag(playlistId),
                        title: title,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.txtHint,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (t > 0.85)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.greyBlur.withOpacity(0.35),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ResizablePlaylistHeaderDelegate oldDelegate) {
    return oldDelegate.coverUrl != coverUrl ||
        oldDelegate.title != title ||
        oldDelegate.meta != meta;
  }
}
