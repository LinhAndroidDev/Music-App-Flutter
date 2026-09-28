import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../core/playback/sleep_timer_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../discover/utils/format_duration.dart';

class SongOptionsSheet extends StatelessWidget {
  const SongOptionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.purpleDark2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => const SongOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final playback = Get.find<PlaybackController>();

    return SafeArea(
      child: Obx(() {
        final timer = playback.sleepTimerState.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.song_options,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _OptionTile(
              title: l10n.sleep_timer_menu,
              subtitle: timer.active ? _remainingLabel(l10n, timer) : null,
              onTap: () => _openSleepTimer(context, playback),
            ),
            _OptionTile(
              title: l10n.song_options_add_library,
              onTap: () => _stub(context),
            ),
            _OptionTile(
              title: l10n.song_options_add_playlist,
              onTap: () => _stub(context),
            ),
            _OptionTile(
              title: l10n.song_options_play_next,
              onTap: () => _stub(context),
            ),
            const SizedBox(height: 8),
          ],
        );
      }),
    );
  }

  String? _remainingLabel(dynamic l10n, SleepTimerState timer) {
    if (timer.stopAtEndOfTrack) return l10n.sleep_timer_end_of_track;
    final ends = timer.endsAtEpochMs;
    if (ends == null) return null;
    final remainingMs = ends - DateTime.now().millisecondsSinceEpoch;
    if (remainingMs <= 0) return l10n.sleep_timer_expired;
    return l10n.sleep_timer_remaining_text(
      remaining: formatDurationMs(remainingMs),
    );
  }

  void _stub(BuildContext context) {
    Navigator.pop(context);
    Get.snackbar('', 'Tính năng sắp có', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _openSleepTimer(BuildContext context, PlaybackController playback) async {
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.purpleDark2,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.sleep_timer_title, style: const TextStyle(color: AppColors.white)),
              ),
              _sleepRow(ctx, l10n.sleep_timer_15, () => playback.setSleepTimer(SleepTimerOption.min15)),
              _sleepRow(ctx, l10n.sleep_timer_30, () => playback.setSleepTimer(SleepTimerOption.min30)),
              _sleepRow(ctx, l10n.sleep_timer_45, () => playback.setSleepTimer(SleepTimerOption.min45)),
              _sleepRow(ctx, l10n.sleep_timer_60, () => playback.setSleepTimer(SleepTimerOption.hour1)),
              _sleepRow(ctx, l10n.sleep_timer_end_of_track, () => playback.setSleepTimer(SleepTimerOption.endOfTrack)),
              _sleepRow(ctx, l10n.sleep_timer_custom, () => _customTimer(ctx, playback, l10n)),
              if (playback.sleepTimerState.value.active)
                _sleepRow(ctx, l10n.sleep_timer_cancel, () => playback.cancelSleepTimer()),
            ],
          ),
        );
      },
    );
  }

  Widget _sleepRow(BuildContext ctx, String label, VoidCallback onTap) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: AppColors.white)),
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
    );
  }

  Future<void> _customTimer(
    BuildContext ctx,
    PlaybackController playback,
    dynamic l10n,
  ) async {
    var hours = 0;
    var minutes = 15;
    await showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.sleep_timer_custom_title),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: hours,
                items: List.generate(
                  5,
                  (h) => DropdownMenuItem(value: h, child: Text('$h ${l10n.sleep_timer_hours}')),
                ),
                onChanged: (v) => hours = v ?? 0,
              ),
              DropdownButton<int>(
                value: minutes,
                items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i * 5,
                    child: Text('${i * 5} ${l10n.sleep_timer_minutes}'),
                  ),
                ),
                onChanged: (v) => minutes = v ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.sleep_timer_cancel),
            ),
            TextButton(
              onPressed: () {
                final totalMs = (hours * 60 + minutes) * 60 * 1000;
                if (totalMs < 60 * 1000) {
                  Get.snackbar('', l10n.sleep_timer_custom_invalid);
                  return;
                }
                Navigator.pop(dialogCtx);
                Navigator.pop(ctx);
                Navigator.pop(ctx);
                playback.setSleepTimer(
                  SleepTimerOption.custom,
                  customDurationMs: totalMs,
                );
              },
              child: Text(l10n.sleep_timer_confirm),
            ),
          ],
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.title, this.subtitle, required this.onTap});

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppColors.white)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: AppColors.white.withOpacity(0.6)))
          : null,
      onTap: onTap,
    );
  }
}
