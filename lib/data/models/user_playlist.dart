import 'package:cloud_firestore/cloud_firestore.dart';

class UserPlaylist {
  const UserPlaylist({
    required this.id,
    required this.title,
    required this.isPublic,
    required this.songCount,
    required this.coverUrl,
    required this.createdAt,
  });

  final String id;
  final String title;
  final bool isPublic;
  final int songCount;
  final String coverUrl;
  final int createdAt;

  factory UserPlaylist.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserPlaylist(
      id: doc.id,
      title: data['title'] as String? ?? '',
      isPublic: data['isPublic'] as bool? ?? true,
      songCount: _asInt(data['songCount']),
      coverUrl: data['coverUrl'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0,
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
