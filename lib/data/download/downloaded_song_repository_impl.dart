import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

import '../models/song.dart';
import '../playback/download_enqueue_result.dart';
import '../playback/downloaded_song_repository.dart';
import 'download_database.dart';
import 'download_file_store.dart';
import 'download_status.dart';
import 'downloaded_song_dao.dart';
import 'downloaded_song_entity.dart';
import 'song_download_scheduler.dart';

class DownloadedSongRepositoryImpl extends DownloadedSongRepository {
  DownloadedSongRepositoryImpl._({
    required DownloadedSongDao dao,
    required DownloadFileStore fileStore,
  })  : _dao = dao,
        _fileStore = fileStore;

  final DownloadedSongDao _dao;
  final DownloadFileStore _fileStore;
  late final SongDownloadScheduler _scheduler;

  @override
  final completedSongs = <Song>[].obs;

  @override
  final completedCount = 0.obs;

  final _statusControllers = <String, StreamController<DownloadStatus?>>{};

  static Future<DownloadedSongRepositoryImpl> create() async {
    final database = await DownloadDatabase.open();
    final dao = DownloadedSongDao(database.db);
    final fileStore = DownloadFileStore();
    await fileStore.ensureDirs();

    final repo = DownloadedSongRepositoryImpl._(
      dao: dao,
      fileStore: fileStore,
    );
    repo._scheduler = SongDownloadScheduler(
      repository: repo,
      dao: dao,
      fileStore: fileStore,
    );
    await repo.refreshCompleted();
    return repo;
  }

  static Future<void> install() async {
    if (Get.isRegistered<DownloadedSongRepository>()) {
      await Get.find<DownloadedSongRepository>().refreshCompleted();
      return;
    }
    final repo = await create();
    Get.put<DownloadedSongRepository>(repo, permanent: true);
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshCompleted());
  }

  @override
  Future<DownloadEnqueueResult> enqueueDownload(Song song) async {
    if (song.id.isEmpty || song.audioUrl.trim().isEmpty) {
      return DownloadEnqueueResult.invalidSong;
    }

    final existing = await _dao.getById(song.id);
    if (existing != null && existing.status == DownloadStatus.completed) {
      final path = existing.localAudioPath;
      if (path.isNotEmpty && await File(path).exists()) {
        return DownloadEnqueueResult.alreadyDownloaded;
      }
    }

    await enqueueMetadata(song);
    await _scheduler.schedule(song);
    return DownloadEnqueueResult.started;
  }

  Future<void> enqueueMetadata(Song song) async {
    final entity = DownloadedSongEntity.fromSong(
      song,
      status: DownloadStatus.queued,
    );
    await _dao.upsert(entity);
    _emitStatus(song.id, DownloadStatus.queued);
  }

  @override
  Future<void> cancelDownload(String songId) async {
    _scheduler.cancel(songId);
    final entity = await _dao.getById(songId);
    if (entity != null && entity.status == DownloadStatus.queued) {
      await _dao.updateStatus(songId, DownloadStatus.failed);
      _emitStatus(songId, DownloadStatus.failed);
    }
  }

  @override
  Future<void> deleteDownload(String songId) async {
    _scheduler.cancel(songId);
    await _fileStore.deleteFilesForSong(songId);
    await _dao.deleteById(songId);
    _emitStatus(songId, null);
    await refreshCompleted();
  }

  @override
  Stream<DownloadStatus?> watchStatus(String songId) {
    final controller = _statusControllers.putIfAbsent(
      songId,
      () => StreamController<DownloadStatus?>.broadcast(),
    );
    unawaited(getStatus(songId).then(controller.add));
    return controller.stream;
  }

  @override
  Future<DownloadStatus?> getStatus(String songId) async {
    final entity = await _dao.getById(songId);
    return entity?.status;
  }

  @override
  Future<String?> resolveLocalPlayableUri(String songId) async {
    final entity = await _dao.getById(songId);
    if (entity == null || entity.status != DownloadStatus.completed) {
      return null;
    }
    final path = await _resolveStoredAudioPath(entity);
    return path;
  }

  @override
  Future<String?> resolveLocalLyricPath(String songId) async {
    final entity = await _dao.getById(songId);
    if (entity == null || entity.status != DownloadStatus.completed) {
      return null;
    }
    final path = entity.localLyricPath.trim();
    if (path.isEmpty) return null;
    if (!await File(path).exists()) return null;
    return path;
  }

  Future<void> markDownloading(String songId) async {
    await _dao.updateStatus(songId, DownloadStatus.downloading);
    _emitStatus(songId, DownloadStatus.downloading);
  }

  Future<void> markFailed(String songId) async {
    await _dao.updateStatus(songId, DownloadStatus.failed);
    _emitStatus(songId, DownloadStatus.failed);
  }

  Future<void> markCompleted({
    required String songId,
    required String localAudioPath,
    required String localLyricPath,
  }) async {
    await _dao.updateDownloadResult(
      songId: songId,
      status: DownloadStatus.completed,
      localAudioPath: localAudioPath,
      localLyricPath: localLyricPath,
      downloadedAt: DateTime.now().millisecondsSinceEpoch,
    );
    _emitStatus(songId, DownloadStatus.completed);
    await refreshCompleted();
  }

  @override
  Future<void> refreshCompleted() async {
    final entities = await _dao.listByStatus(DownloadStatus.completed);
    final songs = <Song>[];
    for (final entity in entities) {
      final path = await _resolveStoredAudioPath(entity);
      if (path != null) {
        songs.add(entity.toSong());
      }
    }
    completedSongs.assignAll(songs);
    completedCount.value = songs.length;
  }

  Future<String?> _resolveStoredAudioPath(DownloadedSongEntity entity) async {
    var path = entity.localAudioPath.trim();
    if (path.isNotEmpty && await File(path).exists()) {
      return path;
    }

    final file = await _fileStore.findExistingAudioFile(entity.songId);
    if (file == null) return null;

    final repaired = file.path;
    if (repaired != path) {
      await _dao.updateDownloadResult(
        songId: entity.songId,
        status: DownloadStatus.completed,
        localAudioPath: repaired,
        localLyricPath: entity.localLyricPath,
        downloadedAt: entity.downloadedAt > 0
            ? entity.downloadedAt
            : DateTime.now().millisecondsSinceEpoch,
      );
    }
    return repaired;
  }

  void _emitStatus(String songId, DownloadStatus? status) {
    final controller = _statusControllers[songId];
    if (controller != null && !controller.isClosed) {
      controller.add(status);
    }
  }

  @override
  void onClose() {
    for (final controller in _statusControllers.values) {
      unawaited(controller.close());
    }
    _statusControllers.clear();
    super.onClose();
  }
}
