import 'song.dart';

class FavouriteSongRecord {
  const FavouriteSongRecord({
    required this.song,
    required this.createdAtMillis,
  });

  final Song song;
  final int createdAtMillis;
}
