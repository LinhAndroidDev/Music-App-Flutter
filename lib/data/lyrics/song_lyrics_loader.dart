import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/song.dart';
import '../playback/downloaded_song_repository.dart';
import 'lrc_line_parser.dart';
import 'lyric_text_decoder.dart';
import 'timed_lyric_line.dart';

class SongLyricsLoader extends GetxService {
  Future<List<TimedLyricLine>?> loadTimedLines(Song song) async {
    try {
      final text = await _loadLyricText(song);
      if (text == null || text.trim().isEmpty) return null;
      final parsed = LrcLineParser.parse(text);
      return parsed.isEmpty ? null : parsed;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _loadLyricText(Song song) async {
    if (Get.isRegistered<DownloadedSongRepository>()) {
      final downloads = Get.find<DownloadedSongRepository>();
      final localPath = await downloads.resolveLocalLyricPath(song.id);
      if (localPath != null && localPath.isNotEmpty) {
        return File(localPath).readAsString();
      }
    }

    final url = song.lyricUrl.trim();
    if (url.isEmpty) return null;
    if (url.startsWith('file:')) {
      final file = File.fromUri(Uri.parse(url));
      if (await file.exists()) {
        return file.readAsString();
      }
      return null;
    }
    return _downloadText(url);
  }

  Future<String> _downloadText(String urlString) async {
    final response = await http
        .get(Uri.parse(urlString))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw StateError('HTTP ${response.statusCode}');
    }
    return decodeLyricHttpBody(response);
  }
}
