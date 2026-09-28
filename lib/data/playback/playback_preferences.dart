import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/playback/repeat_mode.dart';

class PlaybackPreferences extends GetxService {
  static const _keyRepeat = 'music_app_type_repeat';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<RepeatMode> getRepeatMode() async {
    final prefs = await _ensurePrefs();
    return RepeatMode.fromStored(prefs.getInt(_keyRepeat) ?? 0);
  }

  RepeatMode getRepeatModeSync() {
    final prefs = _prefs;
    if (prefs == null) return RepeatMode.notRepeat;
    return RepeatMode.fromStored(prefs.getInt(_keyRepeat) ?? 0);
  }

  Future<void> saveRepeatMode(RepeatMode mode) async {
    final prefs = await _ensurePrefs();
    await prefs.setInt(_keyRepeat, mode.storedValue);
  }

  Future<void> warmUp() async {
    await _ensurePrefs();
  }
}
