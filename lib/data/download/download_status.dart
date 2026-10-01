/// Mirrors ServiceMusic [DownloadStatus].
enum DownloadStatus {
  queued,
  downloading,
  completed,
  failed;

  static DownloadStatus? fromDb(String? value) {
    if (value == null || value.isEmpty) return null;
    return DownloadStatus.values.asNameMap()[value];
  }

  String get dbValue => name;
}
