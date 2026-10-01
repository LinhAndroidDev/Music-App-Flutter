import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../core/playback/playback_state.dart' as app_playback;
import '../../../core/playback/sleep_timer_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/service_music_dialog.dart';
import '../../../data/download/download_status.dart';
import '../../../data/models/song.dart';
import '../../../data/playback/download_enqueue_result.dart';
import '../../../data/playback/downloaded_song_repository.dart';
import '../../../data/services/favourite_song_repository.dart';
import '../../discover/utils/format_duration.dart';
import '../../library/widgets/confirm_remove_song_dialog.dart';
import '../../playlist/widgets/pick_playlist_sheet.dart';
import '../song_options_config.dart';

const _sheetTopRadius = Radius.circular(15);
const _iconSize = 25.0;

/// ServiceMusic [layout_bottom_sheet_option_music.xml].
class SongOptionsSheet extends StatefulWidget {
  const SongOptionsSheet({
    super.key,
    required this.song,
    required this.config,
  });

  final Song song;
  final SongOptionsConfig config;

  static Future<void> show(
    BuildContext context, {
    required Song song,
    SongOptionsConfig config = SongOptionsConfig.list,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: SongOptionsSheet.sheetShape,
      builder: (ctx) => SongOptionsSheet(song: song, config: config),
    );
  }

  static ShapeBorder get sheetShape => const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: _sheetTopRadius),
      );

  @override
  State<SongOptionsSheet> createState() => _SongOptionsSheetState();
}

class _SongOptionsSheetState extends State<SongOptionsSheet> {
  final _favourites = Get.find<FavouriteSongRepository>();
  final _downloads = Get.find<DownloadedSongRepository>();
  StreamSubscription<bool>? _favSub;
  StreamSubscription<DownloadStatus?>? _downloadSub;
  bool _isFavourite = false;
  DownloadStatus? _downloadStatus;

  Song get song => widget.song;

  @override
  void initState() {
    super.initState();
    _favSub = _favourites.watchIsFavourite(song.id).listen((v) {
      if (mounted) setState(() => _isFavourite = v);
    });
    _downloadSub = _downloads.watchStatus(song.id).listen((status) {
      if (mounted) setState(() => _downloadStatus = status);
    });
  }

  @override
  void dispose() {
    _favSub?.cancel();
    _downloadSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final playback = Get.find<PlaybackController>();
    final config = widget.config;

    return SafeArea(
      top: false,
      child: Obx(() {
        final timer = playback.sleepTimerState.value;
        final timerActive = config.showSleepTimer && timer.active;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: song.thumbnailUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: song.thumbnailUrl,
                                fit: BoxFit.cover,
                              )
                            : const ColoredBox(color: AppColors.purpleDark1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            song.nameSinger,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.txtHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(AppAssets.imgShare, width: 25, height: 25),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const _SheetDivider(),
              if (config.showRemoveFromPlaylist)
                _OptionMusicRow(
                  marginTop: 10,
                  icon: AppAssets.icRemove,
                  title: l10n.playlist_remove_song,
                  onTap: () => _removeFromPlaylist(context),
                ),
              if (config.showSleepTimer)
                _OptionMusicRow(
                  marginTop: 10,
                  icon: timerActive ? AppAssets.icTimerFill : AppAssets.icTimer,
                  iconColor: timerActive ? AppColors.purple1 : AppColors.black,
                  title: l10n.sleep_timer_menu,
                  titleColor:
                      timerActive ? AppColors.purple1 : AppColors.textBlack,
                  onTap: () => _SleepTimerSheet.show(context),
                ),
              _DownloadOptionRow(
                marginTop: 10,
                status: _downloadStatus,
                onTap: () => _onDownloadTap(context),
              ),
              _OptionMusicRow(
                icon: _isFavourite ? AppAssets.icFavouriteFill : AppAssets.icFavouriteThin,
                iconColor: _isFavourite ? AppColors.purple1 : AppColors.black,
                title: _isFavourite
                    ? l10n.song_options_added_library
                    : l10n.song_options_add_library,
                onTap: () => _onFavouriteTap(context),
              ),
              _OptionMusicRow(
                icon: AppAssets.icPlaylist,
                title: l10n.playlist_add_title,
                onTap: () => _onAddToPlaylist(context),
              ),
              _OptionMusicRow(
                icon: AppAssets.icContentSame,
                title: l10n.song_options_play_similar,
                onTap: () => _stub(context),
              ),
              _OptionMusicRow(
                icon: AppAssets.icAddPlaylist,
                title: l10n.song_options_add_playlist,
                onTap: () => _onAddToPlaylist(context),
              ),
              _OptionMusicRow(
                icon: AppAssets.icPlaylistNext,
                title: l10n.song_options_play_next,
                onTap: () => _stub(context),
              ),
              _OptionMusicRow(
                icon: AppAssets.icRingtone,
                title: l10n.song_options_ringtone,
                onTap: () => _stub(context),
              ),
              _OptionMusicRow(
                icon: AppAssets.icLibraryMusic,
                title: l10n.song_options_view_album,
                onTap: () => _stub(context),
              ),
              _OptionMusicRow(
                icon: AppAssets.icArtist,
                title: l10n.song_options_view_artist,
                onTap: () => _stub(context),
              ),
              _OptionMusicRow(
                marginBottom: 30,
                icon: AppAssets.icBlock,
                title: l10n.song_options_block,
                onTap: () => _stub(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _onFavouriteTap(BuildContext context) async {
    if (!_isFavourite) {
      await _favourites.toggleFavourite(song);
      return;
    }
    final custom = widget.config.onRemoveFavourite;
    if (!context.mounted) return;
    Navigator.pop(context);
    if (custom != null) {
      await custom();
      return;
    }
    final ok = await showConfirmRemoveSongDialog(context, song.title);
    if (ok == true) {
      await _favourites.removeFavourite(song.id);
    }
  }

  Future<void> _removeFromPlaylist(BuildContext context) async {
    Navigator.pop(context);
    await widget.config.onRemoveFromPlaylist?.call();
  }

  Future<void> _onAddToPlaylist(BuildContext context) async {
    Navigator.pop(context);
    await PickPlaylistSheet.show(context, song);
  }

  Future<void> _onDownloadTap(BuildContext context) async {
    final l10n = context.l10n;
    final status = _downloadStatus;
    if (status == DownloadStatus.downloading || status == DownloadStatus.queued) {
      return;
    }
    Navigator.pop(context);
    if (status == DownloadStatus.completed) {
      await _downloads.deleteDownload(song.id);
      if (!context.mounted) return;
      showAppToast(l10n.toast_removed_download);
      return;
    }
    final result = await _downloads.enqueueDownload(song);
    if (!context.mounted) return;
    switch (result) {
      case DownloadEnqueueResult.started:
        showAppToast(l10n.download_started);
      case DownloadEnqueueResult.alreadyDownloaded:
        showAppToast(l10n.download_already_done);
      case DownloadEnqueueResult.invalidSong:
        break;
    }
  }

  void _stub(BuildContext context) {
    Navigator.pop(context);
    showAppToast('Tính năng sắp có');
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(height: 0.8, color: AppColors.greyLight),
    );
  }
}

class _DownloadOptionRow extends StatelessWidget {
  const _DownloadOptionRow({
    required this.status,
    required this.onTap,
    this.marginTop = 0,
  });

  final DownloadStatus? status;
  final VoidCallback onTap;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy =
        status == DownloadStatus.downloading || status == DownloadStatus.queued;
    final completed = status == DownloadStatus.completed;
    final title = completed
        ? l10n.download_remove_action
        : busy
            ? l10n.download_status_downloading
            : l10n.download_action;
    return Opacity(
      opacity: busy ? 0.5 : 1,
      child: _OptionMusicRow(
        marginTop: marginTop,
        icon: AppAssets.icDownloadThin,
        title: title,
        onTap: busy ? () {} : onTap,
      ),
    );
  }
}

class _OptionMusicRow extends StatelessWidget {
  const _OptionMusicRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = AppColors.black,
    this.titleColor = AppColors.textBlack,
    this.marginTop = 0,
    this.marginBottom = 0,
  });

  final String icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final VoidCallback onTap;
  final double marginTop;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: marginTop, bottom: marginBottom),
      child: Material(
        color: AppColors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                AppIcon(icon, size: _iconSize, color: iconColor),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, color: titleColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ServiceMusic [layout_bottom_sheet_sleep_timer.xml] + [BottomSheetSleepTimer.kt].
class _SleepTimerSheet extends StatefulWidget {
  const _SleepTimerSheet();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: SongOptionsSheet.sheetShape,
      builder: (ctx) => const _SleepTimerSheet(),
    );
  }

  @override
  State<_SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<_SleepTimerSheet> {
  final _playback = Get.find<PlaybackController>();
  Timer? _ticker;
  Worker? _timerWorker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _timerWorker = ever(_playback.sleepTimerState, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _timerWorker?.dispose();
    super.dispose();
  }

  int _remainingMs(SleepTimerState timer, app_playback.PlaybackState playback) {
    if (!timer.active) return 0;
    if (timer.stopAtEndOfTrack) {
      return (playback.durationMs - playback.positionMs).clamp(0, 1 << 31);
    }
    final ends = timer.endsAtEpochMs;
    if (ends == null) return 0;
    return (ends - DateTime.now().millisecondsSinceEpoch).clamp(0, 1 << 31);
  }

  Future<void> _onOption(SleepTimerOption option) async {
    final timer = _playback.sleepTimerState.value;
    if (timer.active && timer.option == option) {
      _playback.cancelSleepTimer();
      if (mounted) Navigator.pop(context);
      return;
    }
    if (option == SleepTimerOption.custom) {
      await _showCustomDialog();
      return;
    }
    await _playback.setSleepTimer(option);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _showCustomDialog() async {
    await ServiceMusicDialog.show<void>(
      context,
      child: _CustomSleepTimerDialog(
        onConfirm: (totalMs) {
          Navigator.pop(context);
          _playback.setSleepTimer(
            SleepTimerOption.custom,
            customDurationMs: totalMs,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timer = _playback.sleepTimerState.value;
    final playback = _playback.playbackState.value;
    final remainingMs = _remainingMs(timer, playback);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              l10n.sleep_timer_title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ),
          const _SheetDivider(),
          _SleepTimerOptionRow(
            marginTop: 5,
            option: SleepTimerOption.min15,
            timer: timer,
            remainingMs: remainingMs,
            defaultLabel: l10n.sleep_timer_15,
            l10n: l10n,
            onTap: () => _onOption(SleepTimerOption.min15),
          ),
          _SleepTimerOptionRow(
            option: SleepTimerOption.min30,
            timer: timer,
            remainingMs: remainingMs,
            defaultLabel: l10n.sleep_timer_30,
            l10n: l10n,
            onTap: () => _onOption(SleepTimerOption.min30),
          ),
          _SleepTimerOptionRow(
            option: SleepTimerOption.min45,
            timer: timer,
            remainingMs: remainingMs,
            defaultLabel: l10n.sleep_timer_45,
            l10n: l10n,
            onTap: () => _onOption(SleepTimerOption.min45),
          ),
          _SleepTimerOptionRow(
            option: SleepTimerOption.hour1,
            timer: timer,
            remainingMs: remainingMs,
            defaultLabel: l10n.sleep_timer_60,
            l10n: l10n,
            onTap: () => _onOption(SleepTimerOption.hour1),
          ),
          _SleepTimerOptionRow(
            option: SleepTimerOption.endOfTrack,
            timer: timer,
            remainingMs: remainingMs,
            defaultLabel: l10n.sleep_timer_end_of_track,
            l10n: l10n,
            onTap: () => _onOption(SleepTimerOption.endOfTrack),
          ),
          _SleepTimerOptionRow(
            marginBottom: 30,
            option: SleepTimerOption.custom,
            timer: timer,
            remainingMs: remainingMs,
            defaultLabel: l10n.sleep_timer_custom,
            l10n: l10n,
            onTap: () => _onOption(SleepTimerOption.custom),
          ),
        ],
      ),
    );
  }
}

class _SleepTimerOptionRow extends StatelessWidget {
  const _SleepTimerOptionRow({
    required this.option,
    required this.timer,
    required this.remainingMs,
    required this.defaultLabel,
    required this.l10n,
    required this.onTap,
    this.marginTop = 0,
    this.marginBottom = 0,
  });

  final SleepTimerOption option;
  final SleepTimerState timer;
  final int remainingMs;
  final String defaultLabel;
  final dynamic l10n;
  final VoidCallback onTap;
  final double marginTop;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    final isSelected = timer.active && timer.option == option;
    final remaining = formatDurationMs(remainingMs);

    return Padding(
      padding: EdgeInsets.only(top: marginTop, bottom: marginBottom),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: isSelected
              ? _CancelRemainingLabel(
                  full: l10n.sleep_timer_cancel_remaining(remaining: remaining),
                  highlight: l10n.sleep_timer_remaining_text(remaining: remaining),
                )
              : Text(
                  defaultLabel,
                  style: const TextStyle(fontSize: 16, color: AppColors.textBlack),
                ),
        ),
      ),
    );
  }
}

class _CancelRemainingLabel extends StatelessWidget {
  const _CancelRemainingLabel({required this.full, required this.highlight});

  final String full;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final start = full.indexOf(highlight);
    if (start < 0) {
      return Text(full, style: const TextStyle(fontSize: 16, color: AppColors.textBlack));
    }
    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 16, color: AppColors.textBlack),
        children: [
          TextSpan(text: full.substring(0, start)),
          TextSpan(
            text: highlight,
            style: const TextStyle(color: AppColors.purple1),
          ),
          TextSpan(text: full.substring(start + highlight.length)),
        ],
      ),
    );
  }
}

class _CustomSleepTimerDialog extends StatefulWidget {
  const _CustomSleepTimerDialog({required this.onConfirm});

  final ValueChanged<int> onConfirm;

  @override
  State<_CustomSleepTimerDialog> createState() => _CustomSleepTimerDialogState();
}

class _CustomSleepTimerDialogState extends State<_CustomSleepTimerDialog> {
  int _hours = 0;
  int _minutes = 15;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ServiceMusicDialogTitle(l10n.sleep_timer_custom_title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PickerColumn(
                label: l10n.sleep_timer_hours,
                itemCount: 5,
                initialItem: _hours,
                labelBuilder: (i) => '$i',
                onChanged: (v) => _hours = v,
              ),
              const SizedBox(width: 28),
              _PickerColumn(
                label: l10n.sleep_timer_minutes,
                itemCount: 12,
                initialItem: _minutes ~/ 5,
                labelBuilder: (i) => '${i * 5}',
                onChanged: (v) => _minutes = v * 5,
              ),
            ],
          ),
        ),
        ServiceMusicDialogPrimaryButton(
          label: l10n.sleep_timer_confirm,
          onTap: () {
            final totalMs = (_hours * 60 + _minutes) * 60 * 1000;
            if (totalMs < 60 * 1000) {
              showAppToast(l10n.sleep_timer_custom_invalid, category: AppToastCategory.player);
              return;
            }
            Navigator.pop(context);
            widget.onConfirm(totalMs);
          },
        ),
        ServiceMusicDialogCancelButton(
          label: l10n.sleep_timer_cancel,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _PickerColumn extends StatefulWidget {
  const _PickerColumn({
    required this.label,
    required this.itemCount,
    required this.initialItem,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final int itemCount;
  final int initialItem;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onChanged;

  @override
  State<_PickerColumn> createState() => _PickerColumnState();
}

class _PickerColumnState extends State<_PickerColumn> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: widget.initialItem.clamp(0, widget.itemCount - 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120,
          width: 72,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 36,
            diameterRatio: 1.4,
            physics: const FixedExtentScrollPhysics(),
            controller: _controller,
            onSelectedItemChanged: widget.onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.itemCount,
              builder: (context, index) {
                return Center(
                  child: Text(
                    widget.labelBuilder(index),
                    style: const TextStyle(fontSize: 20, color: AppColors.textBlack),
                  ),
                );
              },
            ),
          ),
        ),
        Text(widget.label, style: const TextStyle(fontSize: 14, color: AppColors.txtHint)),
      ],
    );
  }
}
