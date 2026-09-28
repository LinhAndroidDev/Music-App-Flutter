import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/song.dart';
import 'lrc_line_parser.dart';
import 'lyric_text_decoder.dart';
import 'timed_lyric_line.dart';

class SongLyricsLoader extends GetxService {
  Future<List<TimedLyricLine>?> loadTimedLines(Song song) async {
    try {
      final url = song.lyricUrl.trim();
      if (url.isEmpty) return null;
      final text = await _downloadText(url);
      final parsed = LrcLineParser.parse(text);
      return parsed.isEmpty ? null : parsed;
    } catch (_) {
      return null;
    }
  }

  Future<String> _downloadText(String urlString) async {
    if (urlString.startsWith('file:')) {
      throw UnsupportedError('Local lyric file not wired yet');
    }
    final response = await http
        .get(Uri.parse(urlString))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw StateError('HTTP ${response.statusCode}');
    }
    return decodeLyricHttpBody(response);
  }
}
