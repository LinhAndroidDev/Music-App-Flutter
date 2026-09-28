import 'package:get/get.dart';

import '../models/song.dart';
import 'downloaded_song_repository.dart';

/// Placeholder until local download DB is ported (Room → drift/sqflite).
class DownloadedSongRepositoryStub extends DownloadedSongRepository {
  @override
  final completedSongs = <Song>[].obs;

  @override
  final completedCount = 0.obs;

  @override
  Future<String?> resolveLocalPlayableUri(String songId) async => null;
}
