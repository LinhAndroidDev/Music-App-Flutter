import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_route.dart';

/// Temporary scaffold for secondary routes until real UI is implemented.
///
/// Song list screens must call [playVisibleSongList] from
/// `lib/modules/library/utils/library_playback.dart` (or `song_list_playback.dart`)
/// when implementing row tap → full player + mini player.
class StackPage extends StatelessWidget {
  const StackPage({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Get.currentRoute,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(subtitle!),
            ],
          ],
        ),
      ),
    );
  }
}

String _param(String key) => Get.parameters[key] ?? '';

Widget categorySongsPage(BuildContext context) {
  final l10n = context.l10n;
  final title = _param(AppRouteParam.title);
  final mode = _param(AppRouteParam.mode);
  final categoryId = _param(AppRouteParam.categoryId);
  return StackPage(
    title: title.isNotEmpty ? title : l10n.home_topics_title,
    subtitle: 'mode=$mode\ncategoryId=$categoryId',
  );
}

Widget singerDetailPage(BuildContext context) {
  return StackPage(
    title: context.l10n.artist_info_title,
    subtitle: 'singerId=${_param(AppRouteParam.singerId)}',
  );
}
