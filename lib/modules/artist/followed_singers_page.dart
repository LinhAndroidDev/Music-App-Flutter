import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../library/widgets/library_subpage_header.dart';
import 'followed_singers_controller.dart';
import 'widgets/followed_singer_row.dart';

class FollowedSingersPage extends GetView<FollowedSingersController> {
  const FollowedSingersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LibrarySubpageHeader(title: l10n.artist_screen_title, centerTitle: true),
            Expanded(
              child: Obx(() {
                final singers = controller.singers;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    if (singers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 36, 4, 24),
                        child: Text(
                          l10n.artist_empty,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: AppColors.txtHint),
                        ),
                      ),
                    ...singers.map(
                      (singer) => FollowedSingerRow(
                        singer: singer,
                        onTap: () => controller.openSingerDetail(singer),
                      ),
                    ),
                    AddArtistFooterRow(onTap: controller.openAddArtist),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
