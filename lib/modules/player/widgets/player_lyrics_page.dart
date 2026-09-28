import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/lyrics/timed_lyric_line.dart';
import '../lyrics/lyric_line_index.dart';
import '../player_controller.dart';
import 'lyric_line_tile.dart';

class PlayerLyricsPage extends StatefulWidget {
  const PlayerLyricsPage({super.key, required this.isPageVisible});

  /// ServiceMusic only auto-scrolls when [FragmentMusic.PAGE_LYRICS] is shown.
  final bool isPageVisible;

  @override
  State<PlayerLyricsPage> createState() => _PlayerLyricsPageState();
}

class _PlayerLyricsPageState extends State<PlayerLyricsPage> {
  static const _scrollAnimMaxMs = 700;
  static const _lyricsSyncThrottleMs = 220;

  /// Rough row height for [LyricLineTile] (22sp bold + padding) — builds off-screen rows via jumpTo.
  static const _estimatedRowExtent = 38.0;

  final _scrollController = ScrollController();
  final _playback = Get.find<PlaybackController>();
  final _player = Get.find<PlayerController>();

  int _activeIndex = -1;
  int _lastSeekSequence = 0;
  int _lastLyricsSyncAtMs = 0;
  int _lastScrollAnchor = -1;
  int? _pendingScrollAnchor;
  List<GlobalKey> _rowKeys = [];
  Worker? _playbackWorker;
  Worker? _lyricsWorker;

  @override
  void initState() {
    super.initState();
    _playbackWorker = ever(_playback.playbackState, _onPlaybackTick);
    _lyricsWorker = ever(_player.lyricLines, _onLyricLinesChanged);
    _onLyricLinesChanged(_player.lyricLines.value);
  }

  @override
  void didUpdateWidget(PlayerLyricsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPageVisible && !oldWidget.isPageVisible) {
      _syncScrollToCurrentPosition(smooth: true);
    }
  }

  void _onLyricLinesChanged(List<TimedLyricLine>? lines) {
    final count = lines?.length ?? 0;
    if (_rowKeys.length != count) {
      _rowKeys = List.generate(count, (_) => GlobalKey());
      _lastScrollAnchor = -1;
      _pendingScrollAnchor = null;
      _activeIndex = -1;
    }
    if (lines != null && lines.isNotEmpty && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyActiveLine(
          lines,
          _playback.playbackState.value.positionMs,
          scrollInstant: true,
        );
      });
    }
  }

  void _syncScrollToCurrentPosition({required bool smooth}) {
    final lines = _player.lyricLines.value;
    if (lines == null || lines.isEmpty) return;
    _lastScrollAnchor = -1;
    _pendingScrollAnchor = null;
    _applyActiveLine(
      lines,
      _playback.playbackState.value.positionMs,
      scrollInstant: !smooth,
      forceScroll: true,
    );
  }

  @override
  void dispose() {
    _playbackWorker?.dispose();
    _lyricsWorker?.dispose();
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
      _lastScrollAnchor = -1;
      _applyActiveLine(lines, state.positionMs, scrollInstant: false, forceScroll: true);
      return;
    }

    if (state.isPlaying) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastLyricsSyncAtMs < _lyricsSyncThrottleMs) return;
      _lastLyricsSyncAtMs = now;
    }

    _applyActiveLine(lines, state.positionMs, scrollInstant: false);
  }

  int _anchorForActiveIndex(int activeIndex, int lineCount) {
    if (activeIndex < 0) return -1;
    return (activeIndex - 1).clamp(0, lineCount - 1);
  }

  void _applyActiveLine(
    List<TimedLyricLine> lines,
    int positionMs, {
    bool scrollInstant = false,
    bool forceScroll = false,
  }) {
    final next = activeLineIndexAt(lines, positionMs);
    final highlightChanged = next != _activeIndex;
    if (highlightChanged) {
      setState(() => _activeIndex = next);
    }

    if (next < 0) return;

    final anchor = _anchorForActiveIndex(next, lines.length);

    if (!widget.isPageVisible) {
      _pendingScrollAnchor = anchor;
      return;
    }

    if (!forceScroll && !scrollInstant && !highlightChanged && anchor == _lastScrollAnchor) {
      return;
    }
    _lastScrollAnchor = anchor;
    _pendingScrollAnchor = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToAnchor(
        anchor,
        instant: scrollInstant,
        attempt: 0,
        didPreScroll: false,
      );
    });
  }

  void _jumpNearAnchor(int anchor) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final target = (anchor * _estimatedRowExtent).clamp(0.0, max);
    _scrollController.jumpTo(target);
  }

  void _scrollToAnchor(
    int anchor, {
    required bool instant,
    required int attempt,
    required bool didPreScroll,
  }) {
    if (anchor < 0 || anchor >= _rowKeys.length) return;

    final ctx = _rowKeys[anchor].currentContext;
    if (ctx == null) {
      if (!didPreScroll) {
        _jumpNearAnchor(anchor);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAnchor(
            anchor,
            instant: instant,
            attempt: attempt + 1,
            didPreScroll: true,
          );
        });
        return;
      }
      if (attempt < 10) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAnchor(
            anchor,
            instant: instant,
            attempt: attempt + 1,
            didPreScroll: didPreScroll,
          );
        });
      }
      return;
    }

    if (_scrollController.hasClients && _scrollController.position.isScrollingNotifier.value) {
      _scrollController.jumpTo(_scrollController.offset);
    }

    Scrollable.ensureVisible(
      ctx,
      alignment: 0,
      duration: instant
          ? Duration.zero
          : const Duration(milliseconds: _scrollAnimMaxMs),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _seekToLine(TimedLyricLine line) async {
    final st = _playback.playbackState.value;
    if (!st.hasActivePlayer) return;
    var ms = line.startMs;
    final dur = st.durationMs;
    if (dur > 0) ms = ms.clamp(0, dur);
    _lastScrollAnchor = -1;
    await _playback.seekToMs(ms);
  }

  /// Shrinks the lyrics viewport above transport — same idea as
  /// `item_music_lyrics_page` FrameLayout `paddingBottom` (not ListView scroll padding).
  static const _viewportBottomInset = 32.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: _viewportBottomInset),
      child: Obx(() {
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 15,
              ),
            ),
          );
        }

        if (_rowKeys.length != lines.length) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.bgPurple),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          clipBehavior: Clip.none,
          cacheExtent: 1200,
          itemCount: lines.length,
          itemBuilder: (context, i) {
            return KeyedSubtree(
              key: _rowKeys[i],
              child: LyricLineTile(
                line: lines[i],
                selected: i == _activeIndex,
                onTap: () => _seekToLine(lines[i]),
              ),
            );
          },
        );
      }),
    );
  }
}
