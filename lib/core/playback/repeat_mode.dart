/// Playback repeat mode (ServiceMusic [Repeat] ordinals).
enum RepeatMode {
  notRepeat,
  repeatAll,
  repeatOne;

  static RepeatMode fromStored(int value) {
    return RepeatMode.values[value.clamp(0, RepeatMode.values.length - 1)];
  }

  int get storedValue => index;
}
