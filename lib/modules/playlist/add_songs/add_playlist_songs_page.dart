import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/navigation/app_navigate.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../artist/widgets/add_artist_search_bar.dart';
import '../../library/widgets/library_song_row.dart';
import '../../player/app_player_shell.dart';
import 'add_playlist_songs_controller.dart';

class AddPlaylistSongsPage extends GetView<AddPlaylistSongsController> {
  const AddPlaylistSongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: AppNavigate.back,
                    child: const AppIcon(AppAssets.icBackThin, size: 25, color: AppColors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.playlist_add_songs_title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AddArtistSearchBar(
                hintText: l10n.playlist_search_hint,
                onChanged: controller.onQueryChanged,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final songs = controller.displaySongs;
                if (songs.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.playlist_search_empty,
                      style: const TextStyle(color: AppColors.txtHint, fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(left: 20, bottom: AppPlayerShell.scrollListBottomInset),
                  itemCount: songs.length,
                  itemBuilder: (_, i) {
                    final song = songs[i];
                    final added = controller.addedSongIds.contains(song.id);
                    return Row(
                      children: [
                        Expanded(
                          child: LibrarySongRow(
                            song: song,
                            onTap: added ? null : () => controller.addSong(song),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16, top: 15),
                          child: IconButton(
                            onPressed: added ? null : () => controller.addSong(song),
                            icon: Icon(
                              added ? Icons.check : Icons.add,
                              color: added ? AppColors.txtHint : AppColors.purple1,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
