class TimedLyricLine {
  const TimedLyricLine({required this.startSec, required this.text});

  final double startSec;
  final String text;

  int get startMs => (startSec * 1000).round();
}
