import '../../../data/lyrics/timed_lyric_line.dart';

/// Matches ServiceMusic [FragmentMusic.LYRIC_TIME_EPS] / [activeLineIndexAt].
const lyricTimeEpsilonSec = 1e-4;

/// Index of the active lyric line at [positionMs], or `-1` before the first line starts.
int activeLineIndexAt(List<TimedLyricLine> lines, int positionMs) {
  if (lines.isEmpty) return -1;
  final t = positionMs / 1000.0 + lyricTimeEpsilonSec;
  if (t < lines.first.startSec) return -1;
  var last = -1;
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].startSec <= t) {
      last = i;
    }
  }
  return last;
}
