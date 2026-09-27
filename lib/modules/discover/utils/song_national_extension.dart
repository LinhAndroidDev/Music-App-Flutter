import '../../../data/models/song.dart';
import '../models/home_national.dart';

extension SongNationalFilter on Song {
  bool matchesNational(HomeNational filter) {
    switch (filter) {
      case HomeNational.vietnam:
        return categoryName.contains('Việt') ||
            categoryName.toLowerCase().contains('viet');
      case HomeNational.international:
        if (categoryName.isEmpty) return false;
        return !categoryName.contains('Việt') &&
            !categoryName.toLowerCase().contains('viet');
      case HomeNational.all:
        return true;
    }
  }
}
