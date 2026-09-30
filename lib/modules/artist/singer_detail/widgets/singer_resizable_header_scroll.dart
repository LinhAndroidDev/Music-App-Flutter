import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../singer_shared_element.dart';
import '../../widgets/singer_hero_widgets.dart';
import 'singer_follow_play_buttons.dart';

/// Collapsing singer header: avatar, name, song count, follow/play → compact row with back.
class SingerResizableHeaderScroll extends StatelessWidget {
  const SingerResizableHeaderScroll({
    super.key,
    required this.singerId,
    required this.onBack,
    required this.avatarUrl,
    required this.name,
    required this.songCountText,
    required this.isFollowed,
    required this.onFollow,
    required this.onPlay,
    required this.buttonsEnabled,
    required this.slivers,
  });

  final String singerId;
  final VoidCallback onBack;
  final String avatarUrl;
  final String name;
  final String songCountText;
  final bool isFollowed;
  final VoidCallback onFollow;
  final VoidCallback onPlay;
  final bool buttonsEnabled;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SingerHeaderDelegate(
            singerId: singerId,
            onBack: onBack,
            avatarUrl: avatarUrl,
            name: name,
            songCountText: songCountText,
            isFollowed: isFollowed,
            onFollow: onFollow,
            onPlay: onPlay,
            buttonsEnabled: buttonsEnabled,
          ),
        ),
        ...slivers,
      ],
    );
  }
}

class _SingerHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SingerHeaderDelegate({
    required this.singerId,
    required this.onBack,
    required this.avatarUrl,
    required this.name,
    required this.songCountText,
    required this.isFollowed,
    required this.onFollow,
    required this.onPlay,
    required this.buttonsEnabled,
  });

  final String singerId;
  final VoidCallback onBack;
  final String avatarUrl;
  final String name;
  final String songCountText;
  final bool isFollowed;
  final VoidCallback onFollow;
  final VoidCallback onPlay;
  final bool buttonsEnabled;

  static const _expandedAvatar = 140.0;
  static const _collapsedAvatar = 40.0;
  static const _backSize = 25.0;
  static const _paddingH = 20.0;
  static const _gapAfterBack = 12.0;
  static const _gapAfterAvatar = 12.0;
  static const _textBlockHeight = 36.0;
  static const _buttonsBlockHeight = 42.0;
  static const _expandedTopInset = 12.0;

  static const _contentExpandedHeight =
      16 + _expandedAvatar + 16 + 26 + 4 + 14 + 16 + _buttonsBlockHeight + 16;

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
    final avatarSize = lerpDouble(_expandedAvatar, _collapsedAvatar, t)!;
    final titleFontSize = lerpDouble(22, 16, t)!;
    final buttonsOpacity = (1 - t * 1.35).clamp(0.0, 1.0);

    return ColoredBox(
      color: AppColors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headerW = constraints.maxWidth;
          final headerH = constraints.maxHeight;

          final backTop = lerpDouble(_expandedTopInset, (headerH - _backSize) / 2, t)!;

          final avatarLeftExpanded = (headerW - avatarSize) / 2;
          final avatarLeftCollapsed = _paddingH + _backSize + _gapAfterBack;
          final avatarLeft = lerpDouble(avatarLeftExpanded, avatarLeftCollapsed, t)!;

          final avatarTopExpanded = _expandedTopInset + _backSize + 16;
          final avatarTop = lerpDouble(avatarTopExpanded, (headerH - avatarSize) / 2, t)!;

          final textTopBelowAvatar = avatarTop + avatarSize + 16;
          final textTopBesideAvatar = avatarTop + (avatarSize - _textBlockHeight) / 2;
          final textTop = lerpDouble(textTopBelowAvatar, textTopBesideAvatar, t)!;

          final textLeftExpanded = _paddingH;
          final textLeftCollapsed = avatarLeft + avatarSize + _gapAfterAvatar;
          final textLeft = lerpDouble(textLeftExpanded, textLeftCollapsed, t)!;
          final textRight = lerpDouble(_paddingH, _paddingH, t)!;

          final textAlignment = Alignment.lerp(Alignment.topCenter, Alignment.centerLeft, t)!;

          final buttonsTop = avatarTopExpanded +
              _expandedAvatar +
              16 +
              26 +
              4 +
              14 +
              16;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: _paddingH,
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
                left: avatarLeft,
                top: avatarTop,
                child: SingerHeroAvatar(
                  tag: SingerSharedElement.avatarTag(singerId),
                  avatarUrl: avatarUrl,
                  size: avatarSize,
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
                      SingerHeroName(
                        tag: SingerSharedElement.nameTag(singerId),
                        title: name,
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
                        songCountText,
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
              Positioned(
                left: 24,
                right: 24,
                top: buttonsTop,
                child: Opacity(
                  opacity: buttonsOpacity,
                  child: IgnorePointer(
                    ignoring: buttonsOpacity < 0.05,
                    child: SingerFollowPlayButtons(
                      isFollowed: isFollowed,
                      enabled: buttonsEnabled,
                      onFollow: onFollow,
                      onPlay: onPlay,
                    ),
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
  bool shouldRebuild(covariant _SingerHeaderDelegate oldDelegate) {
    return oldDelegate.avatarUrl != avatarUrl ||
        oldDelegate.name != name ||
        oldDelegate.songCountText != songCountText ||
        oldDelegate.isFollowed != isFollowed ||
        oldDelegate.buttonsEnabled != buttonsEnabled;
  }
}
