import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DownloadDatabase {
  DownloadDatabase._(this.db);

  final Database db;

  static const _dbName = 'music_downloads.db';
  static const _version = 1;

  static Database? _shared;

  static Future<DownloadDatabase> open({String? path}) async {
    if (path != null) {
      final db = await _openDatabaseAt(path);
      return DownloadDatabase._(db);
    }
    if (_shared != null && _shared!.isOpen) {
      return DownloadDatabase._(_shared!);
    }
    final dbPath = await _resolveDatabasePath();
    _shared = await _openDatabaseAt(dbPath);
    return DownloadDatabase._(_shared!);
  }

  static Future<String> _resolveDatabasePath() async {
    final docs = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(p.join(docs.path, 'downloads'));
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    final preferred = p.join(downloadsDir.path, _dbName);
    if (await File(preferred).exists()) {
      return preferred;
    }

    final legacy = p.join(await getDatabasesPath(), _dbName);
    if (await File(legacy).exists()) {
      return legacy;
    }

    return preferred;
  }

  static Future<Database> _openDatabaseAt(String dbPath) async {
    return openDatabase(
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
  }

  /// Connection is kept for the app process (avoid close/reopen races on hot restart).
  Future<void> close() async {}
}
