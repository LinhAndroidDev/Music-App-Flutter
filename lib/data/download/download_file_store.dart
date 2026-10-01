import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local paths for downloaded audio/lyrics (ServiceMusic filesDir/downloads).
class DownloadFileStore {
  DownloadFileStore({Directory? root}) : _root = root;

  Directory? _root;

  Future<void> ensureDirs() async {
    await audioDir();
    await lyricsDir();
  }

  Future<Directory> _downloadsRoot() async {
    _root ??= Directory(p.join((await getApplicationDocumentsDirectory()).path, 'downloads'));
    if (!await _root!.exists()) {
      await _root!.create(recursive: true);
    }
    return _root!;
  }

  Future<Directory> audioDir() async {
    final dir = Directory(p.join((await _downloadsRoot()).path, 'audio'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> lyricsDir() async {
    final dir = Directory(p.join((await _downloadsRoot()).path, 'lyrics'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> tempAudioFile(String songId) async {
    return File(p.join((await audioDir()).path, '$songId.part'));
  }

  Future<File> finalAudioFile(String songId, String remoteUrl) async {
    final ext = audioExtensionFromUrl(remoteUrl);
    return File(p.join((await audioDir()).path, '$songId.$ext'));
  }

  Future<File> tempLyricFile(String songId) async {
    return File(p.join((await lyricsDir()).path, '$songId.part'));
  }

  Future<File> finalLyricFile(String songId) async {
    return File(p.join((await lyricsDir()).path, '$songId.txt'));
  }

  /// Visible for tests.
  static String audioExtensionFromUrl(String remoteUrl) {
    final ext = remoteUrl.split('.').last.split('?').first;
    if (ext.isEmpty) return 'mp3';
    return ext.length > 5 ? 'mp3' : ext;
  }

  Future<void> deleteFilesForSong(String songId) async {
    for (final dir in [await audioDir(), await lyricsDir()]) {
      await for (final entity in dir.list()) {
        if (entity is File && p.basename(entity.path).startsWith(songId)) {
          await entity.delete();
        }
      }
    }
  }
}
