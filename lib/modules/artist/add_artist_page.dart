import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import 'add_artist_controller.dart';
import 'widgets/add_artist_grid_tile.dart';

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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const AppIcon(AppAssets.icClose, size: 24, color: AppColors.black),
                  ),
                  Expanded(
                    child: Text(
                      l10n.artist_add,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Obx(
                    () => TextButton(
                      onPressed: controller.isSaving.value ? null : controller.complete,
                      child: Text(l10n.artist_add_complete),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.artist_add_search_hint,
                  prefixIcon: const AppIcon(AppAssets.icSearch, size: 20, color: AppColors.txtHint),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: controller.setQuery,
              ),
            ),
            Expanded(
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
                      style: const TextStyle(color: AppColors.txtHint),
                    ),
                  );
                }
                final selected = controller.selectedIds;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
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
          ],
        ),
      ),
    );
  }
}
