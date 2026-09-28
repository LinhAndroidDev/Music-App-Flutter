import '../models/favourite_song_record.dart';
import '../models/song.dart';
import '../models/song_arrangement.dart';

List<Song> sortFavouriteRecords(
  List<FavouriteSongRecord> source,
  SongArrangement arrangement,
) {
  int compareVi(String a, String b) =>
      a.toLowerCase().compareTo(b.toLowerCase());

  final sorted = switch (arrangement) {
    SongArrangement.newest =>
      [...source]..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis)),
    SongArrangement.oldest =>
      [...source]..sort((a, b) => a.createdAtMillis.compareTo(b.createdAtMillis)),
    SongArrangement.bySongName =>
      [...source]..sort((a, b) => compareVi(a.song.title, b.song.title)),
    SongArrangement.byArtistName =>
      [...source]..sort((a, b) => compareVi(a.song.nameSinger, b.song.nameSinger)),
  };
  return sorted.map((r) => r.song).toList();
}
