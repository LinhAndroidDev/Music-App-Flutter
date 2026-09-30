import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_navigate.dart';
import '../../core/navigation/app_navigation_route.dart';
import '../../core/playback/playback_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/chrome_top_shadow.dart';
import '../../data/models/song.dart';
import '../library/utils/library_playback.dart';
import '../player/app_player_shell.dart';
import '../player/music_player_coordinator.dart';
import '../player/show_song_options.dart';
import 'search_controller.dart';
import 'widgets/search_chip_section.dart';
import 'widgets/search_committed_tabs.dart';
import 'widgets/search_preview_list.dart';
import 'widgets/search_text_field.dart';
import 'widgets/voice_search_dialog.dart';

class SearchPage extends GetView<MusicSearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      // Keep full-height layout so the mic FAB tracks IME like ServiceMusic translationY.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 15, 10),
                  child: Row(
                    children: [
                      const InkWell(
                        onTap: AppNavigate.back,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: AppIcon(AppAssets.icBackThin, size: 25, color: AppColors.black),
                        ),
                      ),
                      Expanded(
                        child: SearchTextField(
                          controller: controller.searchFieldController,
                          focusNode: controller.searchFocusNode,
                          hintText: l10n.playlist_search_hint,
                          onChanged: controller.onFieldChanged,
                          onSubmitted: controller.onSearchSubmitted,
                          onClear: controller.clearField,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    final state = controller.uiState.value;
                    controller.fieldText.value;
                    Get.find<PlaybackController>().playbackState.value;
                    Get.find<AppNavigationRoute>().currentRoute.value;
                    final chrome = controller.resolveChrome();
                    final bottomPadding = _listBottomPadding(context);

                    switch (chrome) {
                      case SearchChrome.idle:
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: bottomPadding),
                          child: SearchChipSection(
                            recentQueries: state.recentQueries,
                            suggestions: state.suggestions,
                            onRecentTap: controller.applyChipQuery,
                            onRecentDelete: (n) => controller.deleteRecentQuery(n),
                            onClearAllRecent: controller.clearRecentQueries,
                            onSuggestionTap: controller.applyChipQuery,
                          ),
                        );
                      case SearchChrome.loading:
                        return const Center(child: CircularProgressIndicator());
                      case SearchChrome.preview:
                        return SearchPreviewList(
                          relatedNames: state.relatedNames,
                          songs: state.songs,
                          singers: state.singers,
                          bottomPadding: bottomPadding,
                          onRelatedNameTap: controller.applyChipQuery,
                          onSongTap: (s) => _playSong(state.songs, s),
                          onSongMore: (s) => showSongOptions(context, s),
                          onSingerTap: (s) => AppNavigate.toSingerDetail(
                            singerId: s.id,
                            singerName: s.name,
                            singerAvatarUrl: s.avatarUrl,
                          ),
                        );
                      case SearchChrome.tabs:
                        return SearchCommittedTabs(
                          songs: state.songs,
                          singers: state.singers,
                          bottomPadding: bottomPadding,
                          onSongTap: (s) => _playSong(state.songs, s),
                          onSongMore: (s) => showSongOptions(context, s),
                          onSingerTap: (s) => AppNavigate.toSingerDetail(
                            singerId: s.id,
                            singerName: s.name,
                            singerAvatarUrl: s.avatarUrl,
                          ),
                        );
                    }
                  }),
                ),
              ],
            ),
            Obx(() {
              Get.find<PlaybackController>().playbackState.value;
              Get.find<AppNavigationRoute>().currentRoute.value;
              Get.find<AppNavigationRoute>().modalRouteCount.value;
              MediaQuery.viewInsetsOf(context).bottom;
              final bottom = _microFabBottom(context);
              return Positioned(
                right: 15,
                bottom: bottom,
                child: VoiceSearchFab(
                  onTap: () => VoiceSearchDialog.show(
                    context,
                    onResult: controller.setQueryFromVoice,
                  ),
                  icon: const AppIcon(
                    AppAssets.icMicroFill,
                    size: 35,
                    color: AppColors.blue,
                  ),
                ),
              );
            }),
          ],
          ),
        ),
      ),
    );
  }

  void _playSong(List<Song> songs, Song song) {
    playVisibleSongList(songs, song.id);
  }

  double _listBottomPadding(BuildContext context) {
    return _chromeOverlayHeight(context) + 8;
  }

  /// Offset from physical bottom (see [MediaQuery.removePadding] on search [Stack]).
  double _microFabBottom(BuildContext context) {
    const gapAboveChrome = 12.0;
    final ime = MediaQuery.viewInsetsOf(context).bottom;
    if (ime > 0) {
      return gapAboveChrome + ime;
    }
    return gapAboveChrome + _chromeOverlayHeight(context);
  }

  double _chromeOverlayHeight(BuildContext context) {
    final nav = Get.find<AppNavigationRoute>();
    final playback = Get.find<PlaybackController>();
    final coordinator = Get.find<MusicPlayerCoordinator>();
    if (!nav.showsAppChrome || coordinator.isOpen.value) {
      return 0;
    }
    final state = playback.playbackState.value;
    final showMiniBar =
        state.hasActivePlayer && state.currentSong != null;
    return AppPlayerShell.bottomContentInset(
      context,
      showBottomBar: true,
      showMiniBar: showMiniBar,
    );
  }
}
