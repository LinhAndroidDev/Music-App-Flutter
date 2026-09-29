/// Accent-insensitive Vietnamese text (ServiceMusic [VietnameseFold.kt]).
class VietnameseFold {
  VietnameseFold._();

  static final RegExp _combiningMarks = RegExp(r'\p{M}+', unicode: true);
  static final RegExp _extraSpaces = RegExp(r'\s+');

  static String fold(String input) {
    final nfd = _toNfd(input.trim())
        .replaceAll('đ', 'd')
        .replaceAll('Đ', 'd');
    return nfd
        .replaceAll(_combiningMarks, '')
        .toLowerCase()
        .replaceAll(_extraSpaces, ' ')
        .trim();
  }

  static bool contains(String haystack, String foldedNeedle) {
    if (foldedNeedle.isEmpty) return false;
    return fold(haystack).contains(foldedNeedle);
  }

  static bool matches(String haystack, String query) {
    final foldedQuery = fold(query);
    if (foldedQuery.isEmpty) return false;
    return fold(haystack).contains(foldedQuery);
  }

  /// NFD decomposition for Latin + Vietnamese precomposed letters.
  static String _toNfd(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      final decomposed = _nfdMap[ch];
      if (decomposed != null) {
        buffer.write(decomposed);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static const Map<String, String> _nfdMap = {
    'à': 'a\u0300',
    'á': 'a\u0301',
    'ả': 'a\u0309',
    'ã': 'a\u0303',
    'ạ': 'a\u0323',
    'ă': 'a\u0306',
    'ằ': 'a\u0306\u0300',
    'ắ': 'a\u0306\u0301',
    'ẳ': 'a\u0306\u0309',
    'ẵ': 'a\u0306\u0303',
    'ặ': 'a\u0306\u0323',
    'â': 'a\u0302',
    'ầ': 'a\u0302\u0300',
    'ấ': 'a\u0302\u0301',
    'ẩ': 'a\u0302\u0309',
    'ẫ': 'a\u0302\u0303',
    'ậ': 'a\u0302\u0323',
    'è': 'e\u0300',
    'é': 'e\u0301',
    'ẻ': 'e\u0309',
    'ẽ': 'e\u0303',
    'ẹ': 'e\u0323',
    'ê': 'e\u0302',
    'ề': 'e\u0302\u0300',
    'ế': 'e\u0302\u0301',
    'ể': 'e\u0302\u0309',
    'ễ': 'e\u0302\u0303',
    'ệ': 'e\u0302\u0323',
    'ì': 'i\u0300',
    'í': 'i\u0301',
    'ỉ': 'i\u0309',
    'ĩ': 'i\u0303',
    'ị': 'i\u0323',
    'ò': 'o\u0300',
    'ó': 'o\u0301',
    'ỏ': 'o\u0309',
    'õ': 'o\u0303',
    'ọ': 'o\u0323',
    'ô': 'o\u0302',
    'ồ': 'o\u0302\u0300',
    'ố': 'o\u0302\u0301',
    'ổ': 'o\u0302\u0309',
    'ỗ': 'o\u0302\u0303',
    'ộ': 'o\u0302\u0323',
    'ơ': 'o\u031B',
    'ờ': 'o\u031B\u0300',
    'ớ': 'o\u031B\u0301',
    'ở': 'o\u031B\u0309',
    'ỡ': 'o\u031B\u0303',
    'ợ': 'o\u031B\u0323',
    'ù': 'u\u0300',
    'ú': 'u\u0301',
    'ủ': 'u\u0309',
    'ũ': 'u\u0303',
    'ụ': 'u\u0323',
    'ư': 'u\u031B',
    'ừ': 'u\u031B\u0300',
    'ứ': 'u\u031B\u0301',
    'ử': 'u\u031B\u0309',
    'ữ': 'u\u031B\u0303',
    'ự': 'u\u031B\u0323',
    'ỳ': 'y\u0300',
    'ý': 'y\u0301',
    'ỷ': 'y\u0309',
    'ỹ': 'y\u0303',
    'ỵ': 'y\u0323',
    'À': 'A\u0300',
    'Á': 'A\u0301',
    'Ả': 'A\u0309',
    'Ã': 'A\u0303',
    'Ạ': 'A\u0323',
    'Ă': 'A\u0306',
    'Ằ': 'A\u0306\u0300',
    'Ắ': 'A\u0306\u0301',
    'Ẳ': 'A\u0306\u0309',
    'Ẵ': 'A\u0306\u0303',
    'Ặ': 'A\u0306\u0323',
    'Â': 'A\u0302',
    'Ầ': 'A\u0302\u0300',
    'Ấ': 'A\u0302\u0301',
    'Ẩ': 'A\u0302\u0309',
    'Ẫ': 'A\u0302\u0303',
    'Ậ': 'A\u0302\u0323',
    'È': 'E\u0300',
    'É': 'E\u0301',
    'Ẻ': 'E\u0309',
    'Ẽ': 'E\u0303',
    'Ẹ': 'E\u0323',
    'Ê': 'E\u0302',
    'Ề': 'E\u0302\u0300',
    'Ế': 'E\u0302\u0301',
    'Ể': 'E\u0302\u0309',
    'Ễ': 'E\u0302\u0303',
    'Ệ': 'E\u0302\u0323',
    'Ì': 'I\u0300',
    'Í': 'I\u0301',
    'Ỉ': 'I\u0309',
    'Ĩ': 'I\u0303',
    'Ị': 'I\u0323',
    'Ò': 'O\u0300',
    'Ó': 'O\u0301',
    'Ỏ': 'O\u0309',
    'Õ': 'O\u0303',
    'Ọ': 'O\u0323',
    'Ô': 'O\u0302',
    'Ồ': 'O\u0302\u0300',
    'Ố': 'O\u0302\u0301',
    'Ổ': 'O\u0302\u0309',
    'Ỗ': 'O\u0302\u0303',
    'Ộ': 'O\u0302\u0323',
    'Ơ': 'O\u031B',
    'Ờ': 'O\u031B\u0300',
    'Ớ': 'O\u031B\u0301',
    'Ở': 'O\u031B\u0309',
    'Ỡ': 'O\u031B\u0303',
    'Ợ': 'O\u031B\u0323',
    'Ù': 'U\u0300',
    'Ú': 'U\u0301',
    'Ủ': 'U\u0309',
    'Ũ': 'U\u0303',
    'Ụ': 'U\u0323',
    'Ư': 'U\u031B',
    'Ừ': 'U\u031B\u0300',
    'Ứ': 'U\u031B\u0301',
    'Ử': 'U\u031B\u0309',
    'Ữ': 'U\u031B\u0303',
    'Ự': 'U\u031B\u0323',
    'Ỳ': 'Y\u0300',
    'Ý': 'Y\u0301',
    'Ỷ': 'Y\u0309',
    'Ỹ': 'Y\u0303',
    'Ỵ': 'Y\u0323',
  };
}
