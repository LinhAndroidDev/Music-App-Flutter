import 'package:flutter/material.dart';

enum HomeTopicType {
  newChart,
  top100,
  category,
  seeAll,
}

class HomeTopic {
  const HomeTopic({
    required this.type,
    required this.title,
    this.iconAsset,
    this.backgroundColor = Colors.transparent,
    this.categoryId = '',
  });

  final HomeTopicType type;
  final String title;
  final String? iconAsset;
  final Color backgroundColor;
  final String categoryId;
}

/// Matches Android [CategorySongsMode.name].
abstract final class CategorySongsMode {
  static const latest = 'LATEST';
  static const top = 'TOP';
  static const category = 'CATEGORY';
}
