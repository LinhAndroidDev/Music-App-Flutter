import '../models/firestore_song.dart';
import '../models/song.dart';
import 'search_query.dart';
import 'vietnamese_fold.dart';

/// Client-side search over cached catalogs (ServiceMusic [SearchCatalog.kt]).
class SearchCatalog {
  SearchCatalog._();

  static const resultLimit = 20;
  static const suggestionLimit = 6;
  static const historyLimit = 10;
  static const relatedNameLimit = 3;

  static List<Song> mergeSongs(List<Song> latest, List<Song> top) {
    final byId = <String, Song>{};
    for (final song in latest) {
      if (song.id.isNotEmpty) byId[song.id] = song;
    }
    for (final song in top) {
      if (song.id.isNotEmpty) {
        byId.putIfAbsent(song.id, () => song);
      }
    }
    return byId.values.toList();
  }

  static List<Song> filterSongs(List<Song> songs, String query) {
    final folded = VietnameseFold.fold(query);
    if (folded.isEmpty) return const [];
    return songs
        .where(
          (song) =>
              VietnameseFold.contains(song.title, folded) ||
              VietnameseFold.contains(song.nameSinger, folded) ||
              VietnameseFold.contains(song.categoryName, folded),
        )
        .take(resultLimit)
        .toList();
  }

  static List<FirestoreSinger> filterSingers(
    List<FirestoreSinger> singers,
    String query,
  ) {
    final folded = VietnameseFold.fold(query);
    if (folded.isEmpty) return const [];
    return singers
        .where((s) => VietnameseFold.contains(s.name, folded))
        .take(resultLimit)
        .toList();
  }

  static List<String> relatedNames(
    List<Song> songs,
    List<FirestoreSinger> singers, {
    String query = '',
    int limit = relatedNameLimit,
  }) {
    final titles = _uniqueFoldedNames(songs.map((s) => s.title));
    final artists = _uniqueFoldedNames([
      ...singers.map((s) => s.name),
      ...songs.map((s) => s.nameSinger),
    ]);
    final foldedQuery = VietnameseFold.fold(query);
    final titleQueue = _prioritizeQueryMatches(titles, foldedQuery).toList();
    final artistQueue = _prioritizeQueryMatches(artists, foldedQuery).toList();

    final seen = <String>{};
    final names = <String>[];
    var takeTitle = titleQueue.any((n) => VietnameseFold.contains(n, foldedQuery)) ||
        artistQueue.every((n) => !VietnameseFold.contains(n, foldedQuery));

    while (names.length < limit && (titleQueue.isNotEmpty || artistQueue.isNotEmpty)) {
      final primary = takeTitle ? titleQueue : artistQueue;
      final fallback = takeTitle ? artistQueue : titleQueue;
      final next = (primary.isNotEmpty ? primary.removeAt(0) : null) ??
          (fallback.isNotEmpty ? fallback.removeAt(0) : null);
      if (next == null) break;
      final folded = VietnameseFold.fold(next);
      if (folded.isNotEmpty && seen.add(folded)) {
        names.add(next);
      }
      takeTitle = !takeTitle;
    }
    return names;
  }

  static List<String> _uniqueFoldedNames(Iterable<String> values) {
    final seen = <String>{};
    return values
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .where((candidate) {
          final folded = VietnameseFold.fold(candidate);
          return folded.isNotEmpty && seen.add(folded);
        })
        .toList();
  }

  static List<String> _prioritizeQueryMatches(
    List<String> names,
    String foldedQuery,
  ) {
    if (foldedQuery.isEmpty) return names;
    final matches =
        names.where((n) => VietnameseFold.contains(n, foldedQuery)).toList();
    final rest =
        names.where((n) => !VietnameseFold.contains(n, foldedQuery)).toList();
    return [...matches, ...rest];
  }

  static List<String> pickSuggestions(
    List<String> pool,
    List<SearchQuery> recentQueries, {
    int limit = suggestionLimit,
  }) {
    final recentFolded = recentQueries.map((q) => q.normalizedQuery).toSet();
    final seen = <String>{};
    return pool
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .where((candidate) {
          final folded = VietnameseFold.fold(candidate);
          return folded.isNotEmpty &&
              !recentFolded.contains(folded) &&
              seen.add(folded);
        })
        .take(limit)
        .toList();
  }
}
