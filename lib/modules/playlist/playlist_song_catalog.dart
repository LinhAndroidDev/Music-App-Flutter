import 'package:get/get.dart';

import '../../data/models/song.dart';
import '../../data/services/home_catalog_service.dart';

const playlistSuggestionLimit = 20;

Future<void> ensurePlaylistCatalogLoaded() async {
  final catalog = Get.find<HomeCatalogService>();
  if (catalog.latestSongs.isEmpty || catalog.topSongs.isEmpty) {
    await catalog.refreshAll();
  } else {
    await Future.wait([
      catalog.ensureLatest(),
      catalog.ensureTop(),
    ]);
  }
}

List<Song> mergePlaylistCatalog() {
  final catalog = Get.find<HomeCatalogService>();
  final seen = <String>{};
  final merged = <Song>[];
  for (final s in [...catalog.latestSongs, ...catalog.topSongs]) {
    if (seen.add(s.id)) merged.add(s);
  }
  return merged;
}

List<Song> filterPlaylistCatalog(List<Song> catalog, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return catalog;
  return catalog.where((s) {
    return s.title.toLowerCase().contains(q) ||
        s.nameSinger.toLowerCase().contains(q);
  }).toList();
}

List<Song> randomPlaylistSuggestions(List<Song> catalog, Set<String> excludeIds) {
  return catalog.where((s) => !excludeIds.contains(s.id)).toList()..shuffle();
}
