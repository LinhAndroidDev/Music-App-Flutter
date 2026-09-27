import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSong {
  const FirestoreSong({
    this.id = '',
    this.title = '',
    this.singerIds = const [],
    this.singerNames = const [],
    this.singerId = '',
    this.singerName = '',
    this.categoryId = '',
    this.categoryName = '',
    this.thumbnailUrl = '',
    this.audioUrl = '',
    this.lyricUrl = '',
    this.duration = 0,
    this.views = 0,
    this.createdAt,
  });

  final String id;
  final String title;
  final List<String> singerIds;
  final List<String> singerNames;
  final String singerId;
  final String singerName;
  final String categoryId;
  final String categoryName;
  final String thumbnailUrl;
  final String audioUrl;
  final String lyricUrl;
  final int duration;
  final int views;
  final Timestamp? createdAt;

  List<String> get displaySingerIds =>
      singerIds.isNotEmpty ? singerIds : (singerId.isNotEmpty ? [singerId] : const []);

  List<String> get displaySingerNames => singerNames.isNotEmpty
      ? singerNames
      : (singerName.isNotEmpty ? [singerName] : const []);

  String get artistText => displaySingerNames.join(', ');

  bool get hasLyric => lyricUrl.isNotEmpty;

  factory FirestoreSong.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FirestoreSong(
      id: doc.id,
      title: data['title'] as String? ?? '',
      singerIds: _stringList(data['singerIds']),
      singerNames: _stringList(data['singerNames']),
      singerId: data['singerId'] as String? ?? '',
      singerName: data['singerName'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      audioUrl: data['audioUrl'] as String? ?? '',
      lyricUrl: data['lyricUrl'] as String? ?? '',
      duration: _asInt(data['duration']),
      views: _asInt(data['views']),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'singerIds': singerIds,
        'singerNames': singerNames,
        'singerId': singerId,
        'singerName': singerName,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'thumbnailUrl': thumbnailUrl,
        'audioUrl': audioUrl,
        'lyricUrl': lyricUrl,
        'duration': duration,
        'views': views,
        if (createdAt != null) 'createdAt': createdAt,
      };
}

class FirestoreSinger {
  const FirestoreSinger({
    this.id = '',
    this.name = '',
    this.avatarUrl = '',
    this.description = '',
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String description;

  factory FirestoreSinger.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FirestoreSinger(
      id: doc.id,
      name: data['name'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      description: data['description'] as String? ?? '',
    );
  }
}

class FirestoreCategory {
  const FirestoreCategory({this.id = '', this.name = ''});

  final String id;
  final String name;

  factory FirestoreCategory.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FirestoreCategory(
      id: doc.id,
      name: data['name'] as String? ?? '',
    );
  }
}

class FirestoreAdvertisement {
  const FirestoreAdvertisement({
    this.id = '',
    this.image = '',
    this.update = '',
    this.detail = '',
  });

  final String id;
  final String image;
  final String update;
  final String detail;

  factory FirestoreAdvertisement.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return FirestoreAdvertisement(
      id: doc.id,
      image: data['image'] as String? ?? '',
      update: data['update'] as String? ?? '',
      detail: data['detail'] as String? ?? '',
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return const [];
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
