import 'package:sqflite/sqflite.dart';

import 'download_status.dart';
import 'downloaded_song_entity.dart';

class DownloadedSongDao {
  DownloadedSongDao(this._db);

  final Database _db;

  static const _table = 'downloaded_song';

  Future<void> upsert(DownloadedSongEntity entity) async {
    await _db.insert(
      _table,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DownloadedSongEntity?> getById(String songId) async {
    final rows = await _db.query(
      _table,
      where: 'songId = ?',
      whereArgs: [songId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DownloadedSongEntity.fromMap(rows.first);
  }

  Future<List<DownloadedSongEntity>> listByStatus(DownloadStatus status) async {
    final rows = await _db.query(
      _table,
      where: 'status = ?',
      whereArgs: [status.dbValue],
      orderBy: 'downloadedAt DESC',
    );
    return rows.map(DownloadedSongEntity.fromMap).toList();
  }

  Future<int> countByStatus(DownloadStatus status) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) AS c FROM $_table WHERE status = ?',
      [status.dbValue],
    );
    final value = result.first['c'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  Future<void> updateStatus(String songId, DownloadStatus status) async {
    await _db.update(
      _table,
      {'status': status.dbValue},
      where: 'songId = ?',
      whereArgs: [songId],
    );
  }

  Future<void> updateDownloadResult({
    required String songId,
    required DownloadStatus status,
    required String localAudioPath,
    required String localLyricPath,
    required int downloadedAt,
  }) async {
    await _db.update(
      _table,
      {
        'status': status.dbValue,
        'localAudioPath': localAudioPath,
        'localLyricPath': localLyricPath,
        'downloadedAt': downloadedAt,
      },
      where: 'songId = ?',
      whereArgs: [songId],
    );
  }

  Future<void> deleteById(String songId) async {
    await _db.delete(
      _table,
      where: 'songId = ?',
      whereArgs: [songId],
    );
  }
}
