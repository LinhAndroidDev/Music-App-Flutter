import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/playback/repeat_mode.dart';
import '../models/song_arrangement.dart';

class PlaybackPreferences extends GetxService {
  static const _keyRepeat = 'music_app_type_repeat';
  static const _keyArrangement = 'TYPE_ARRANGEMENT';

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

  Future<SongArrangement> getSongArrangement() async {
    final prefs = await _ensurePrefs();
    return SongArrangement.fromStored(prefs.getInt(_keyArrangement));
  }

  SongArrangement getSongArrangementSync() {
    final prefs = _prefs;
    if (prefs == null) return SongArrangement.newest;
    return SongArrangement.fromStored(prefs.getInt(_keyArrangement));
  }

  Future<void> saveSongArrangement(SongArrangement arrangement) async {
    final prefs = await _ensurePrefs();
    await prefs.setInt(_keyArrangement, arrangement.storedIndex);
  }
}
