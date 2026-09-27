import '../../../data/models/song.dart';

/// Groups songs into pages of [pageSize] (ServiceMusic `songsToHashMap`).
List<List<Song>> chunkSongs(List<Song> songs, {int pageSize = 3}) {
  if (songs.isEmpty || pageSize <= 0) return [];
  final pages = <List<Song>>[];
  for (var i = 0; i < songs.length; i += pageSize) {
    final end = (i + pageSize > songs.length) ? songs.length : i + pageSize;
    pages.add(songs.sublist(i, end));
  }
  return pages;
}
