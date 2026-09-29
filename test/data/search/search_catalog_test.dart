import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/data/models/firestore_song.dart';
import 'package:music_app/data/models/song.dart';
import 'package:music_app/data/search/search_catalog.dart';
import 'package:music_app/data/search/search_history_repository.dart';
import 'package:music_app/data/search/search_query.dart';

void main() {
  Song song(String id, String title, String artist, String category) {
    return Song(
      id: id,
      title: title,
      nameSinger: artist,
      categoryName: category,
    );
  }

  FirestoreSinger singer(String id, String name) {
    return FirestoreSinger(id: id, name: name);
  }

  test('filterSongs matches folded title artist and category', () {
    final songs = [
      song('1', 'Chúng Ta Của Hiện Tại', 'Sơn Tùng M-TP', 'Nhạc Việt'),
      song('2', 'Đom Đóm', 'Jack', 'Nhạc Việt'),
      song('3', 'Shape of You', 'Ed Sheeran', 'Pop'),
    ];

    expect(
      SearchCatalog.filterSongs(songs, 'son tung').map((s) => s.id).toList(),
      ['1'],
    );
    expect(
      SearchCatalog.filterSongs(songs, 'dom dom').map((s) => s.id).toList(),
      ['2'],
    );
    expect(
      SearchCatalog.filterSongs(songs, 'pop').map((s) => s.id).toList(),
      ['3'],
    );
  });

  test('filterSingers matches unsigned name', () {
    final singers = [
      singer('a', 'Sơn Tùng M-TP'),
      singer('b', 'Đen Vâu'),
    ];

    expect(
      SearchCatalog.filterSingers(singers, 'son tung').map((s) => s.id).toList(),
      ['a'],
    );
    expect(
      SearchCatalog.filterSingers(singers, 'den vau').map((s) => s.id).toList(),
      ['b'],
    );
  });

  test('mergeSongs unions latest and top by id', () {
    final latest = [
      song('1', 'Mới', 'A', 'Việt'),
      song('2', 'Cũ hơn', 'B', 'Việt'),
    ];
    final top = [
      song('2', 'Cũ hơn', 'B', 'Việt'),
      song('3', 'Top', 'C', 'Việt'),
    ];

    expect(
      SearchCatalog.mergeSongs(latest, top).map((s) => s.id).toList(),
      ['1', '2', '3'],
    );
  });

  test('relatedNames interleaves titles and singers up to three', () {
    final songs = [
      song('1', 'Sơn Tùng', 'A', 'Việt'),
      song('2', 'son tung', 'B', 'Việt'),
      song('3', 'Chúng Ta Của Hiện Tại', 'C', 'Việt'),
    ];
    final singers = [
      singer('a', 'Sơn Tùng M-TP'),
      singer('b', 'Đen Vâu'),
    ];

    expect(
      SearchCatalog.relatedNames(songs, singers),
      ['Sơn Tùng', 'Sơn Tùng M-TP', 'Chúng Ta Của Hiện Tại'],
    );
  });

  test('relatedNames includes artist when query matches singer', () {
    final songs = [
      song('1', 'Chúng Ta Của Hiện Tại', 'Sơn Tùng M-TP', 'Việt'),
      song('2', 'Nơi Này Có Anh', 'Sơn Tùng M-TP', 'Việt'),
      song('3', 'Có Chắc Yêu Là Đây', 'Sơn Tùng M-TP', 'Việt'),
    ];
    final singers = [singer('a', 'Sơn Tùng M-TP')];

    expect(
      SearchCatalog.relatedNames(songs, singers, query: 'son tung'),
      ['Sơn Tùng M-TP', 'Chúng Ta Của Hiện Tại', 'Nơi Này Có Anh'],
    );
  });

  test('pickSuggestions skips recent folded duplicates', () {
    const pool = ['Sơn Tùng', 'Nhạc Việt', 'Workout', 'son tung'];
    const recent = [SearchQuery(query: 'Sơn Tùng', normalizedQuery: 'son tung', lastSearchedAt: 0)];

    expect(
      SearchCatalog.pickSuggestions(pool, recent),
      ['Nhạc Việt', 'Workout'],
    );
  });

  test('searchQueryDocumentId sanitizes path characters', () {
    expect(searchQueryDocumentId('son tung'), 'son tung');
    expect(searchQueryDocumentId('a/b'), 'a_b');
  });
}
