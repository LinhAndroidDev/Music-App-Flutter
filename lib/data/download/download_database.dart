import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DownloadDatabase {
  DownloadDatabase._(this.db);

  final Database db;

  static const _dbName = 'music_downloads.db';
  static const _version = 1;

  static Future<DownloadDatabase> open({String? path}) async {
    final dbPath = path ?? p.join(await getDatabasesPath(), _dbName);
    final db = await openDatabase(
      dbPath,
      version: _version,
      onCreate: (database, version) async {
        await database.execute('''
CREATE TABLE downloaded_song (
  songId TEXT PRIMARY KEY NOT NULL,
  title TEXT NOT NULL,
  nameSinger TEXT NOT NULL,
  thumbnailUrl TEXT NOT NULL,
  remoteAudioUrl TEXT NOT NULL,
  lyricUrl TEXT NOT NULL,
  durationSec INTEGER NOT NULL,
  categoryId TEXT NOT NULL,
  categoryName TEXT NOT NULL,
  localAudioPath TEXT NOT NULL,
  localLyricPath TEXT NOT NULL,
  status TEXT NOT NULL,
  downloadedAt INTEGER NOT NULL
)
''');
        await database.execute(
          'CREATE INDEX idx_downloaded_song_status ON downloaded_song(status)',
        );
      },
    );
    return DownloadDatabase._(db);
  }

  Future<void> close() => db.close();
}
