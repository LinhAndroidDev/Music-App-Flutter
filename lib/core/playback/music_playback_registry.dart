import 'package:get/get.dart';

import 'music_audio_handler.dart';

/// Holds [MusicAudioHandler] across hot reload (GetX permanent survives reload).
class MusicPlaybackRegistry extends GetxService {
  MusicAudioHandler? handler;
  Future<void>? initFuture;
}
