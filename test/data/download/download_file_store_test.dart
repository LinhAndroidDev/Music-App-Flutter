import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/data/download/download_file_store.dart';

void main() {
  group('audioExtensionFromUrl', () {
    test('uses extension before query string', () {
      expect(
        DownloadFileStore.audioExtensionFromUrl('https://cdn.example.com/a.mp3?token=1'),
        'mp3',
      );
    });

    test('falls back to mp3 when extension too long', () {
      expect(
        DownloadFileStore.audioExtensionFromUrl('https://cdn.example.com/file.verylongext'),
        'mp3',
      );
    });

    test('falls back to mp3 when no extension', () {
      expect(
        DownloadFileStore.audioExtensionFromUrl('https://cdn.example.com/stream'),
        'mp3',
      );
    });
  });
}
