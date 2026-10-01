import 'dart:io';

import 'package:http/http.dart' as http;

import 'download_file_store.dart';
import 'downloaded_song_entity.dart';

/// Ports ServiceMusic [SongDownloadWorker] (HTTP stream to temp file, rename, lyric best-effort).
class SongDownloadWorker {
  SongDownloadWorker({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _maxRetries = 3;
  static const _connectTimeout = Duration(seconds: 20);
  static const _readTimeout = Duration(seconds: 30);

  Future<SongDownloadResult> run({
    required DownloadedSongEntity entity,
    required DownloadFileStore fileStore,
  }) async {
    final songId = entity.songId;
    final remoteUrl = entity.remoteAudioUrl.trim();
    if (remoteUrl.isEmpty) {
      return SongDownloadResult.failure;
    }

    Object? lastError;
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final tempFile = await fileStore.tempAudioFile(songId);
        final finalFile = await fileStore.finalAudioFile(songId, remoteUrl);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }

        await _downloadToFile(remoteUrl, tempFile);
        if (!await tempFile.exists() || await tempFile.length() <= 0) {
          throw StateError('Empty download for $songId');
        }

        if (await finalFile.exists()) {
          await finalFile.delete();
        }
        try {
          await tempFile.rename(finalFile.path);
        } on FileSystemException {
          await tempFile.copy(finalFile.path);
          await tempFile.delete();
        }

        final lyricPath = await _downloadLyricBestEffort(
          songId: songId,
          lyricUrl: entity.lyricUrl,
          fileStore: fileStore,
        );

        return SongDownloadResult.completed(
          localAudioPath: finalFile.path,
          localLyricPath: lyricPath,
        );
      } catch (e) {
        lastError = e;
        final temp = await fileStore.tempAudioFile(songId);
        if (await temp.exists()) {
          await temp.delete();
        }
        if (attempt + 1 >= _maxRetries) break;
      }
    }
    assert(lastError != null);
    return SongDownloadResult.failure;
  }

  Future<String> _downloadLyricBestEffort({
    required String songId,
    required String lyricUrl,
    required DownloadFileStore fileStore,
  }) async {
    final url = lyricUrl.trim();
    if (url.isEmpty) return '';

    final tempLyric = await fileStore.tempLyricFile(songId);
    final finalLyric = await fileStore.finalLyricFile(songId);
    try {
      if (await tempLyric.exists()) await tempLyric.delete();
      await _downloadToFile(url, tempLyric);
      if (!await tempLyric.exists() || await tempLyric.length() <= 0) {
        if (await tempLyric.exists()) await tempLyric.delete();
        return '';
      }
      if (await finalLyric.exists()) await finalLyric.delete();
      try {
        await tempLyric.rename(finalLyric.path);
      } on FileSystemException {
        await tempLyric.copy(finalLyric.path);
        await tempLyric.delete();
      }
      return finalLyric.path;
    } catch (_) {
      if (await tempLyric.exists()) await tempLyric.delete();
      return '';
    }
  }

  Future<void> _downloadToFile(String remoteUrl, File dest) async {
    final request = http.Request('GET', Uri.parse(remoteUrl));
    final response = await _client.send(request).timeout(_connectTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('HTTP ${response.statusCode} for $remoteUrl');
    }

    final sink = dest.openWrite();
    try {
      await for (final chunk in response.stream.timeout(_readTimeout)) {
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }
  }

  void close() => _client.close();
}

class SongDownloadResult {
  const SongDownloadResult._(this.didFail, this.localAudioPath, this.localLyricPath);

  final bool didFail;
  final String localAudioPath;
  final String localLyricPath;

  static const failure = SongDownloadResult._(true, '', '');

  factory SongDownloadResult.completed({
    required String localAudioPath,
    required String localLyricPath,
  }) {
    return SongDownloadResult._(false, localAudioPath, localLyricPath);
  }
}
