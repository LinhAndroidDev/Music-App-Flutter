String formatSongDuration(int durationSec) {
  if (durationSec <= 0) return '';
  final m = durationSec ~/ 60;
  final s = durationSec % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
