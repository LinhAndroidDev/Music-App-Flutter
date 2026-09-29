import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/navigation/app_navigate.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../player/app_player_shell.dart';
import '../widgets/edit_playlist_song_row.dart';
import 'edit_playlist_controller.dart';

class EditPlaylistPage extends GetView<EditPlaylistController> {
  const EditPlaylistPage({super.key});

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
                      l10n.playlist_edit_title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: controller.save,
                    child: Text(
                      l10n.playlist_save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.purple1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  hintText: l10n.playlist_name_hint,
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.playlist_public_label,
                        style: const TextStyle(fontSize: 16, color: AppColors.textBlack),
                      ),
                    ),
                    Switch(
                      value: controller.isPublic.value,
                      activeColor: AppColors.purple1,
                      onChanged: (v) => controller.isPublic.value = v,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final list = controller.songs.toList();
                return ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: AppPlayerShell.scrollListBottomInset),
                  itemCount: list.length,
                  onReorder: controller.reorder,
                  itemBuilder: (context, index) {
                    final song = list[index];
                    return EditPlaylistSongRow(
                      key: ValueKey(song.id),
                      song: song,
                      dragHandle: ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.drag_handle, color: AppColors.txtHint),
                        ),
                      ),
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
