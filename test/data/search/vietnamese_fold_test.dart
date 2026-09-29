import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/data/search/vietnamese_fold.dart';

void main() {
  group('VietnameseFold', () {
    test('fold strips accents and lowercases', () {
      expect(VietnameseFold.fold('Sơn Tùng'), 'son tung');
      expect(VietnameseFold.fold('Đề xuất'), 'de xuat');
      expect(VietnameseFold.fold('  Nghe nhạc  '), 'nghe nhac');
    });

    test('matches finds unsigned query in accented text', () {
      expect(VietnameseFold.matches('Sơn Tùng M-TP', 'son tung'), isTrue);
      expect(VietnameseFold.matches('Đề xuất cho bạn', 'de xuat'), isTrue);
      expect(VietnameseFold.matches('Sơn Tùng', 'jack'), isFalse);
    });

    test('contains uses folded needle', () {
      final folded = VietnameseFold.fold('son tung');
      expect(VietnameseFold.contains('Chúng ta của Sơn Tùng', folded), isTrue);
      expect(VietnameseFold.contains('Jack', folded), isFalse);
    });
  });
}
