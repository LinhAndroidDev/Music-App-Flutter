import 'dart:convert';

import 'package:http/http.dart' as http;

/// Decodes lyric file bytes (LRC) as UTF-8, matching Android [InputStreamReader] behavior.
String decodeLyricHttpBody(http.Response response) {
  final bytes = response.bodyBytes;
  if (bytes.isEmpty) return '';

  final contentType = response.headers['content-type']?.toLowerCase() ?? '';
  final charsetMatch = RegExp(r'charset=([\w-]+)').firstMatch(contentType);
  if (charsetMatch != null) {
    final charset = charsetMatch.group(1)!.toLowerCase();
    final encoding = _encodingForName(charset);
    if (encoding != null) {
      return encoding.decode(bytes);
    }
  }

  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    return utf8.decode(bytes.sublist(3));
  }

  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}

Encoding? _encodingForName(String name) {
  switch (name) {
    case 'utf-8':
    case 'utf8':
      return utf8;
    case 'iso-8859-1':
    case 'latin1':
      return latin1;
    default:
      return null;
  }
}
