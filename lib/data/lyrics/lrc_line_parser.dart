import 'timed_lyric_line.dart';

/// Parses LRC lines: `[mm:ss.SS] lyric text`.
class LrcLineParser {
  static final _lineRegex = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2})]\s*(.*)$');

  static List<TimedLyricLine> parse(String fileText) {
    final out = <TimedLyricLine>[];
    for (final raw in fileText.split('\n')) {
      final line = raw.replaceAll('\r', '').trimRight();
      final match = _lineRegex.firstMatch(line);
      if (match == null) continue;
      final mm = int.parse(match.group(1)!);
      final ss = int.parse(match.group(2)!);
      final centi = int.parse(match.group(3)!);
      final text = match.group(4)!.trim();
      if (text.isEmpty) continue;
      final startSec = mm * 60.0 + ss + centi / 100.0;
      out.add(TimedLyricLine(startSec: startSec, text: text));
    }
    return out;
  }
}
