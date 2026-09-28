import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import 'add_artist_controller.dart';
import 'widgets/add_artist_grid_tile.dart';
import 'widgets/add_artist_search_bar.dart';

class AddArtistPage extends GetView<AddArtistController> {
  const AddArtistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: const AppIcon(AppAssets.icRemove, size: 25, color: AppColors.black),
                  ),
                  Expanded(
                    child: Text(
                      l10n.artist_add,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AddArtistSearchBar(
                hintText: l10n.artist_add_search_hint,
                onChanged: controller.setQuery,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  controller.selectedIds.length;
                  final singers = controller.visibleSingers;
                  if (singers.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.artist_add_empty,
                        style: const TextStyle(fontSize: 14, color: AppColors.txtHint),
                      ),
                    );
                  }
                  final selected = controller.selectedIds;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: singers.length,
                    itemBuilder: (context, index) {
                      final singer = singers[index];
                      return AddArtistGridTile(
                        singer: singer,
                        selected: selected.contains(singer.id),
                        onTap: () => controller.toggleSelection(singer.id),
                      );
                    },
                  );
                }),
              ),
            ),
            Obx(() {
              final saving = controller.isSaving.value;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Center(
                  child: Material(
                    color: AppColors.purple1,
                    borderRadius: BorderRadius.circular(25),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: saving ? null : controller.complete,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                        child: Text(
                          l10n.artist_add_complete,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(saving ? 0.6 : 1),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
