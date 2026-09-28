import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../core/playback/repeat_mode.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../discover/utils/format_duration.dart';
import '../player_controller.dart';

class PlayerTransportControls extends StatefulWidget {
  const PlayerTransportControls({super.key});

  @override
  State<PlayerTransportControls> createState() => _PlayerTransportControlsState();
}

class _PlayerTransportControlsState extends State<PlayerTransportControls> {
  final _playback = Get.find<PlaybackController>();
  final _player = Get.find<PlayerController>();

  bool _isUserSeeking = false;
  double? _seekFractionWhileDragging;

  String _repeatAsset(RepeatMode mode) {
    return switch (mode) {
      RepeatMode.repeatAll => AppAssets.icRepeatAll,
      RepeatMode.repeatOne => AppAssets.icRepeatOne,
      RepeatMode.notRepeat => AppAssets.icNotRepeat,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = _playback.playbackState.value;
      final durationMs = state.durationMs;
      final shuffleTint = state.isShuffleEnabled ? AppColors.bgPurple : AppColors.white;

      final seekFraction = _isUserSeeking && _seekFractionWhileDragging != null
          ? _seekFractionWhileDragging!
          : durationMs > 0
              ? (state.positionMs / durationMs).clamp(0.0, 1.0)
              : 0.0;

      final displayPositionMs = _isUserSeeking && _seekFractionWhileDragging != null && durationMs > 0
          ? (_seekFractionWhileDragging! * durationMs).round()
          : state.positionMs;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: AppColors.bgPurple,
                inactiveTrackColor: AppColors.white.withOpacity(0.25),
                thumbColor: AppColors.white,
              ),
              child: Slider(
                value: seekFraction.clamp(0.0, 1.0),
                onChangeStart: durationMs > 0
                    ? (_) {
                        setState(() => _isUserSeeking = true);
                      }
                    : null,
                onChanged: durationMs > 0
                    ? (v) {
                        setState(() => _seekFractionWhileDragging = v);
                      }
                    : null,
                onChangeEnd: durationMs > 0
                    ? (v) async {
                        setState(() {
                          _isUserSeeking = false;
                          _seekFractionWhileDragging = null;
                        });
                        await _playback.seekToMs((v * durationMs).round());
                      }
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDurationMs(displayPositionMs),
                    style: const TextStyle(color: AppColors.txtGreyBlur, fontSize: 12),
                  ),
                  Text(
                    formatDurationMs(durationMs),
                    style: const TextStyle(color: AppColors.txtGreyBlur, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _player.toggleShuffle(),
                  icon: AppIcon(AppAssets.iconRandom, size: 28, color: shuffleTint),
                ),
                IconButton(
                  onPressed: () => _playback.skipPrevious(),
                  icon: const AppIcon(AppAssets.skipPrevious, size: 36, color: AppColors.white),
                ),
                IconButton(
                  onPressed: () => _playback.playPause(),
                  icon: AppIcon(
                    state.isPlaying ? AppAssets.icPauseMusic : AppAssets.icPlayMusic,
                    size: 72,
                    color: AppColors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => _playback.skipNext(),
                  icon: const AppIcon(AppAssets.skipNext, size: 36, color: AppColors.white),
                ),
                Obx(
                  () => IconButton(
                    onPressed: () => _player.cycleRepeat(),
                    icon: AppIcon(
                      _repeatAsset(_player.repeatMode.value),
                      size: 28,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
