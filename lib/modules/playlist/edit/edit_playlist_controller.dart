import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/navigation/app_navigate.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/navigation/app_route.dart';
import '../../../data/models/song.dart';
import '../../../data/services/playlist_repository.dart';
import '../playlist_mutation_ui.dart';

class EditPlaylistController extends GetxController {
  EditPlaylistController({PlaylistRepository? playlists})
      : _playlists = playlists ?? Get.find<PlaylistRepository>();

  final PlaylistRepository _playlists;

  final playlistId = Get.parameters[AppRouteParam.playlistId] ?? '';

  final titleController = TextEditingController();
  final isPublic = true.obs;
  final songs = <Song>[].obs;

  StreamSubscription? _playlistSub;
  StreamSubscription? _songsSub;
  bool _boundPlaylist = false;

  @override
  void onInit() {
    super.onInit();
    _playlistSub = _playlists.watchPlaylist(playlistId).listen((p) {
      if (p == null || _boundPlaylist) return;
      _boundPlaylist = true;
      titleController.text = p.title;
      isPublic.value = p.isPublic;
    });
    _songsSub = _playlists.watchSongs(playlistId).listen(songs.assignAll);
  }

  @override
  void onClose() {
    _playlistSub?.cancel();
    _songsSub?.cancel();
    titleController.dispose();
    super.onClose();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = songs.toList();
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    songs.assignAll(list);
    _persistOrder();
  }

  Future<void> _persistOrder() async {
    final ids = songs.map((s) => s.id).toList();
    final cover = songs.isNotEmpty ? songs.first.thumbnailUrl : '';
    final result = await _playlists.reorderSongs(
      playlistId: playlistId,
      songIds: ids,
      firstCoverUrl: cover,
    );
    if (result != PlaylistMutationResult.success) {
      showPlaylistMutationSnackbar(result);
    }
  }

  Future<void> save() async {
    final result = await _playlists.updatePlaylist(
      playlistId: playlistId,
      title: titleController.text,
      isPublic: isPublic.value,
    );
    if (result == PlaylistMutationResult.success) {
      final l10n = Get.context?.l10n;
      if (l10n != null) {
        showAppToast(l10n.playlist_updated, category: AppToastCategory.playlist);
      }
      AppNavigate.back();
    } else {
      showPlaylistMutationSnackbar(result);
    }
  }
}
