import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../player_controller.dart';

class PlayerSingerPage extends StatelessWidget {
  const PlayerSingerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final player = Get.find<PlayerController>();

    return Obx(() {
      final state = player.singerState.value;
      if (state.isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.bgPurple),
        );
      }
      if (state.singers.isEmpty) {
        return Center(
          child: Text(
            l10n.singer_info_empty,
            style: TextStyle(color: AppColors.white.withOpacity(0.7)),
          ),
        );
      }

      final index = state.selectedIndex.clamp(0, state.singers.length - 1);
      final singer = state.singers[index];

      return Column(
        children: [
          if (state.singers.length > 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.singers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = i == index;
                  return ChoiceChip(
                    label: Text(state.singers[i].name),
                    selected: selected,
                    onSelected: (_) => player.selectSingerTab(i),
                    selectedColor: AppColors.bgPurple,
                    backgroundColor: AppColors.purpleDark1,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.white : AppColors.txtGreyBlur,
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: singer.avatarUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: singer.avatarUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  Container(color: AppColors.purpleDark1),
                            )
                          : Container(color: AppColors.purpleDark1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    singer.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    singer.description.isNotEmpty
                        ? singer.description
                        : l10n.singer_info_empty,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.75),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
