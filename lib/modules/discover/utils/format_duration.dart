String formatSongDuration(int durationSec) {
  if (durationSec <= 0) return '';
  final m = durationSec ~/ 60;
  final s = durationSec % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String formatDurationMs(int ms) {
  if (ms < 0) ms = 0;
  final totalSec = ms ~/ 1000;
  final m = totalSec ~/ 60;
  final s = totalSec % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
