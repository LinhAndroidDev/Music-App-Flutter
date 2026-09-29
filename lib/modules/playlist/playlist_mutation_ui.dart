import 'package:get/get.dart';

import '../../core/l10n/l10n.dart';
import '../../core/widgets/app_toast.dart';
import '../../data/services/playlist_repository.dart';

void showPlaylistMutationSnackbar(
  PlaylistMutationResult result, {
  String? playlistName,
}) {
  final l10n = Get.context?.l10n;
  if (l10n == null) return;

  final message = switch (result) {
    PlaylistMutationResult.success when playlistName != null && playlistName.isNotEmpty =>
      l10n.playlist_added(playlistName),
    PlaylistMutationResult.success => l10n.playlist_updated,
    PlaylistMutationResult.alreadyExists => l10n.playlist_already_added,
    PlaylistMutationResult.requiresLogin => l10n.playlist_login_required,
    PlaylistMutationResult.offline => l10n.playlist_offline,
    PlaylistMutationResult.failure => l10n.playlist_operation_failed,
  };

  showAppToast(message, category: AppToastCategory.playlist);
}
