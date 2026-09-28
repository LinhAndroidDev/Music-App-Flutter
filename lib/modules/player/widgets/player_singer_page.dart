import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../player_controller.dart';

class PlayerSingerPage extends StatefulWidget {
  const PlayerSingerPage({super.key});

  @override
  State<PlayerSingerPage> createState() => _PlayerSingerPageState();
}

class _PlayerSingerPageState extends State<PlayerSingerPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _tabControllerLength = 0;
  String _tabControllerSongId = '';
  bool _syncingTabFromState = false;

  @override
  void dispose() {
    _tabController?.removeListener(_onTabIndexChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _onTabIndexChanged() {
    if (_syncingTabFromState || _tabController == null || _tabController!.indexIsChanging) {
      return;
    }
    Get.find<PlayerController>().selectSingerTab(_tabController!.index);
  }

  TabController _tabControllerFor(PlayerSingerUiState state, int index) {
    final count = state.singers.length;
    if (_tabController == null ||
        _tabControllerLength != count ||
        _tabControllerSongId != state.songId) {
      _tabController?.removeListener(_onTabIndexChanged);
      _tabController?.dispose();
      _tabController = TabController(
        length: count,
        vsync: this,
        initialIndex: index,
      )..addListener(_onTabIndexChanged);
      _tabControllerLength = count;
      _tabControllerSongId = state.songId;
    } else if (_tabController!.index != index) {
      _syncingTabFromState = true;
      _tabController!.animateTo(index);
      _syncingTabFromState = false;
    }
    return _tabController!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final player = Get.find<PlayerController>();

    return Obx(() {
      final state = player.singerState.value;
      if (state.isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        );
      }
      if (state.singers.isEmpty) {
        return Center(
          child: Text(
            l10n.singer_info_empty,
            style: const TextStyle(color: AppColors.white, fontSize: 15),
          ),
        );
      }

      final index = state.selectedIndex.clamp(0, state.singers.length - 1);
      final singer = state.singers[index];
      final multipleSingers = state.singers.length > 1;
      final tabController = multipleSingers ? _tabControllerFor(state, index) : null;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (multipleSingers && tabController != null) ...[
              TabBar(
                controller: tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: AppColors.blue,
                indicatorWeight: 2,
                labelColor: AppColors.textWhite,
                unselectedLabelColor: AppColors.grey1,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  for (final s in state.singers) Tab(text: s.name),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Center(
              child: ClipOval(
                child: SizedBox(
                  width: 200,
                  height: 200,
                child: singer.avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: singer.avatarUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: AppColors.purpleDark1),
                      )
                    : Container(color: AppColors.purpleDark1),
                ),
              ),
            ),
            if (!multipleSingers) ...[
              const SizedBox(height: 20),
              Text(
                singer.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else
              const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  singer.description.isNotEmpty ? singer.description : l10n.singer_info_empty,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
