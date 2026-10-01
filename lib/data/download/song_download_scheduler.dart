import 'dart:async';
import 'dart:collection';

import '../models/song.dart';
import 'download_file_store.dart';
import 'downloaded_song_dao.dart';
import 'downloaded_song_repository_impl.dart';
import 'song_download_worker.dart';

/// In-app download queue (one active job; dedupe per songId).
class SongDownloadScheduler {
  SongDownloadScheduler({
    required DownloadedSongRepositoryImpl repository,
    required DownloadedSongDao dao,
    required DownloadFileStore fileStore,
    SongDownloadWorker? worker,
  })  : _repository = repository,
        _dao = dao,
        _fileStore = fileStore,
        _worker = worker ?? SongDownloadWorker();

  final DownloadedSongRepositoryImpl _repository;
  final DownloadedSongDao _dao;
  final DownloadFileStore _fileStore;
  final SongDownloadWorker _worker;

  final Set<String> _active = {};
  final Queue<String> _pending = Queue<String>();
  Future<void> schedule(Song song) async {
    if (song.id.isEmpty) return;
    if (_active.contains(song.id)) return;

    if (_active.isEmpty && _pending.isEmpty) {
      _active.add(song.id);
      unawaited(_runJob(song.id));
      return;
    }

    if (!_pending.contains(song.id) && !_active.contains(song.id)) {
      _pending.add(song.id);
    }
  }

  Future<void> _runJob(String songId) async {
    try {
      final entity = await _dao.getById(songId);
      if (entity == null) return;

      await _repository.markDownloading(songId);

      final result = await _worker.run(entity: entity, fileStore: _fileStore);
      if (result.didFail) {
        await _repository.markFailed(songId);
      } else {
        await _repository.markCompleted(
          songId: songId,
          localAudioPath: result.localAudioPath,
          localLyricPath: result.localLyricPath,
        );
      }
    } finally {
      _active.remove(songId);
      if (_pending.isNotEmpty) {
        final next = _pending.removeFirst();
        _active.add(next);
        unawaited(_runJob(next));
      }
    }
  }

  void cancel(String songId) {
    _pending.removeWhere((id) => id == songId);
  }
}
