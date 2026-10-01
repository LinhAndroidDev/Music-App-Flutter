import 'download_status.dart';
import '../models/song.dart';

class DownloadedSongEntity {
  const DownloadedSongEntity({
    required this.songId,
    required this.title,
    required this.nameSinger,
    required this.thumbnailUrl,
    required this.remoteAudioUrl,
    required this.lyricUrl,
    required this.durationSec,
    required this.categoryId,
    required this.categoryName,
    this.localAudioPath = '',
    this.localLyricPath = '',
    this.status = DownloadStatus.queued,
    this.downloadedAt = 0,
  });

  final String songId;
  final String title;
  final String nameSinger;
  final String thumbnailUrl;
  final String remoteAudioUrl;
  final String lyricUrl;
  final int durationSec;
  final String categoryId;
  final String categoryName;
  final String localAudioPath;
  final String localLyricPath;
  final DownloadStatus status;
  final int downloadedAt;

  Song toSong() {
    return Song(
      id: songId,
      title: title,
      nameSinger: nameSinger,
      thumbnailUrl: thumbnailUrl,
      audioUrl: remoteAudioUrl,
      lyricUrl: lyricUrl,
      durationSec: durationSec,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  factory DownloadedSongEntity.fromSong(Song song, {DownloadStatus status = DownloadStatus.queued}) {
    return DownloadedSongEntity(
      songId: song.id,
      title: song.title,
      nameSinger: song.nameSinger,
      thumbnailUrl: song.thumbnailUrl,
      remoteAudioUrl: song.audioUrl,
      lyricUrl: song.lyricUrl,
      durationSec: song.durationSec,
      categoryId: song.categoryId,
      categoryName: song.categoryName,
      status: status,
    );
  }

  factory DownloadedSongEntity.fromMap(Map<String, Object?> map) {
    return DownloadedSongEntity(
      songId: map['songId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      nameSinger: map['nameSinger'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      remoteAudioUrl: map['remoteAudioUrl'] as String? ?? '',
      lyricUrl: map['lyricUrl'] as String? ?? '',
      durationSec: map['durationSec'] as int? ?? 0,
      categoryId: map['categoryId'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      localAudioPath: map['localAudioPath'] as String? ?? '',
      localLyricPath: map['localLyricPath'] as String? ?? '',
      status: DownloadStatus.fromDb(map['status'] as String?) ?? DownloadStatus.failed,
      downloadedAt: map['downloadedAt'] as int? ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'songId': songId,
      'title': title,
      'nameSinger': nameSinger,
      'thumbnailUrl': thumbnailUrl,
      'remoteAudioUrl': remoteAudioUrl,
      'lyricUrl': lyricUrl,
      'durationSec': durationSec,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'localAudioPath': localAudioPath,
      'localLyricPath': localLyricPath,
      'status': status.dbValue,
      'downloadedAt': downloadedAt,
    };
  }
}
