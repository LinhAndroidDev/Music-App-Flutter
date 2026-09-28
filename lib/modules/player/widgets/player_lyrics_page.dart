import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/lyrics/timed_lyric_line.dart';
import '../player_controller.dart';

class PlayerLyricsPage extends StatefulWidget {
  const PlayerLyricsPage({super.key});

  @override
  State<PlayerLyricsPage> createState() => _PlayerLyricsPageState();
}

class _PlayerLyricsPageState extends State<PlayerLyricsPage> {
  static const _scrollAnimMaxMs = 700;
  static const _lyricsSyncThrottleMs = 220;

  final _scrollController = ScrollController();
  final _playback = Get.find<PlaybackController>();
  final _player = Get.find<PlayerController>();

  int _activeIndex = 0;
  int _lastSeekSequence = 0;
  int _lastLyricsSyncAtMs = 0;
  Worker? _playbackWorker;

  @override
  void initState() {
    super.initState();
    _playbackWorker = ever(_playback.playbackState, _onPlaybackTick);
  }

  @override
  void dispose() {
    _playbackWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onPlaybackTick(dynamic _) {
    if (!mounted) return;
    final lines = _player.lyricLines.value;
    if (lines == null || lines.isEmpty) return;

    final state = _playback.playbackState.value;
    if (state.seekSequence != _lastSeekSequence) {
      _lastSeekSequence = state.seekSequence;
      _lastLyricsSyncAtMs = 0;
      _updateActive(lines, state.positionMs, jump: true);
      return;
    }

    if (state.isPlaying) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastLyricsSyncAtMs < _lyricsSyncThrottleMs) return;
      _lastLyricsSyncAtMs = now;
    }

    _updateActive(lines, state.positionMs, jump: false);
  }

  int _indexForPosition(List<TimedLyricLine> lines, int positionMs) {
    var idx = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startMs <= positionMs) {
        idx = i;
      } else {
        break;
      }
    }
    return idx;
  }

  void _updateActive(List<TimedLyricLine> lines, int positionMs, {required bool jump}) {
    final next = _indexForPosition(lines, positionMs);
    if (next == _activeIndex && !jump) return;
    setState(() => _activeIndex = next);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      const lineHeight = 36.0;
      final target = ((next - 1).clamp(0, lines.length - 1)) * lineHeight;
      if (jump) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: _scrollAnimMaxMs),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Obx(() {
      if (_player.lyricsLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.bgPurple),
        );
      }
      final lines = _player.lyricLines.value;
      if (lines == null || lines.isEmpty) {
        return Center(
          child: Text(
            l10n.lyrics_empty,
            style: TextStyle(color: AppColors.white.withOpacity(0.7)),
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        itemCount: lines.length,
        itemBuilder: (context, i) {
          final active = i == _activeIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              lines[i].text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? AppColors.lyricLineActive : AppColors.white.withOpacity(0.55),
                fontSize: active ? 16 : 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                height: 1.35,
              ),
            ),
          );
        },
      );
    });
  }
}
