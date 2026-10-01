import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/data/download/download_database.dart';
import 'package:music_app/data/download/download_status.dart';
import 'package:music_app/data/download/downloaded_song_dao.dart';
import 'package:music_app/data/download/downloaded_song_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DownloadedSongDao', () {
    late DownloadDatabase database;
    late DownloadedSongDao dao;

    setUp(() async {
      database = await DownloadDatabase.open(path: inMemoryDatabasePath);
      dao = DownloadedSongDao(database.db);
    });

    tearDown(() async {
      await database.close();
    });

    test('upsert and getById', () async {
      const entity = DownloadedSongEntity(
        songId: 's1',
        title: 'Title',
        nameSinger: 'Singer',
        thumbnailUrl: '',
        remoteAudioUrl: 'https://example.com/a.mp3',
        lyricUrl: '',
        durationSec: 120,
        categoryId: '',
        categoryName: '',
        status: DownloadStatus.queued,
      );
      await dao.upsert(entity);
      final loaded = await dao.getById('s1');
      expect(loaded?.title, 'Title');
      expect(loaded?.status, DownloadStatus.queued);
    });

    test('updateDownloadResult marks completed', () async {
      const entity = DownloadedSongEntity(
        songId: 's2',
        title: 'T',
        nameSinger: 'S',
        thumbnailUrl: '',
        remoteAudioUrl: 'https://example.com/a.mp3',
        lyricUrl: '',
        durationSec: 1,
        categoryId: '',
        categoryName: '',
        status: DownloadStatus.downloading,
      );
      await dao.upsert(entity);
      await dao.updateDownloadResult(
        songId: 's2',
        status: DownloadStatus.completed,
        localAudioPath: '/tmp/s2.mp3',
        localLyricPath: '',
        downloadedAt: 1000,
      );
      final list = await dao.listByStatus(DownloadStatus.completed);
      expect(list, hasLength(1));
      expect(list.first.localAudioPath, '/tmp/s2.mp3');
    });
  });
}
