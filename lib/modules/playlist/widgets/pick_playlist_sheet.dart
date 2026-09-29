import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/song.dart';
import '../../../data/models/user_playlist.dart';
import '../../../data/services/playlist_repository.dart';
import '../../library/widgets/create_playlist_dialog.dart';
import '../../library/widgets/playlist_list_tile.dart';
import '../playlist_auth.dart';
import '../playlist_mutation_ui.dart';

class PickPlaylistSheet extends StatelessWidget {
  const PickPlaylistSheet({super.key, required this.song});

  final Song song;

  static Future<void> show(BuildContext context, Song song) async {
    final ok = await ensureSignedInForPlaylist(context);
    if (!ok || !context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PickPlaylistSheet(song: song),
    );
  }

  String _meta(dynamic l10n, UserPlaylist p) {
    if (p.isPublic) return l10n.playlist_meta_public(p.songCount);
    return l10n.playlist_meta_private(p.songCount);
  }

  void _closeSheet(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _addToPlaylist(BuildContext context, UserPlaylist playlist) async {
    final repo = Get.find<PlaylistRepository>();
    final result = await repo.addSong(playlist.id, song, currentCoverUrl: playlist.coverUrl);
    _closeSheet(context);
    showPlaylistMutationSnackbar(result, playlistName: playlist.title);
  }

  Future<void> _createAndAdd(BuildContext context) async {
    final l10n = context.l10n;
    final result = await Get.dialog<CreatePlaylistResult>(const CreatePlaylistDialog());
    if (result == null) return;

    final repo = Get.find<PlaylistRepository>();
    final created = await repo.createPlaylist(title: result.title, isPublic: result.isPublic);
    if (created.status != PlaylistMutationResult.success || created.playlistId == null) {
      showPlaylistMutationSnackbar(created.status);
      return;
    }
    final addResult = await repo.addSong(created.playlistId!, song);
    _closeSheet(context);
    if (addResult == PlaylistMutationResult.success) {
      showAppToast(l10n.playlist_added(result.title), category: AppToastCategory.playlist);
    } else {
      showPlaylistMutationSnackbar(addResult, playlistName: result.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = Get.find<PlaylistRepository>();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              l10n.playlist_add_title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ),
          const Divider(height: 0.8, thickness: 0.8, color: AppColors.greyLight),
          Flexible(
            child: Obx(() {
              final list = repo.playlists;
              return ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text(
                      l10n.playlist_create_new,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                    onTap: () => _createAndAdd(context),
                  ),
                  for (final p in list)
                    PlaylistListTile(
                      playlist: p,
                      metaText: _meta(l10n, p),
                      onTap: () => _addToPlaylist(context, p),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
