import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_song.dart';

class Song {
  const Song({
    required this.id,
    required this.title,
    required this.nameSinger,
    this.thumbnailUrl = '',
    this.audioUrl = '',
    this.lyricUrl = '',
    this.durationSec = 0,
    this.categoryId = '',
    this.categoryName = '',
    this.views = 0,
  });

  final String id;
  final String title;
  final String nameSinger;
  final String thumbnailUrl;
  final String audioUrl;
  final String lyricUrl;
  final int durationSec;
  final String categoryId;
  final String categoryName;
  final int views;

  factory Song.fromFirestoreDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final songId = (data['songId'] as String?)?.isNotEmpty == true
        ? data['songId'] as String
        : doc.id;
    return Song(
      id: songId,
      title: data['title'] as String? ?? '',
      nameSinger: data['nameSinger'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      audioUrl: data['audioUrl'] as String? ?? '',
      lyricUrl: data['lyricUrl'] as String? ?? '',
      durationSec: _asInt(data['durationSec']),
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      views: _asInt(data['views']),
    );
  }

  static Song fromFirestoreSong(FirestoreSong fs) {
    return Song(
      id: fs.id,
      title: fs.title,
      nameSinger: fs.artistText.isNotEmpty ? fs.artistText : fs.singerName,
      thumbnailUrl: fs.thumbnailUrl,
      audioUrl: fs.audioUrl,
      lyricUrl: fs.lyricUrl,
      durationSec: fs.duration,
      categoryId: fs.categoryId,
      categoryName: fs.categoryName,
      views: fs.views,
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
