enum SleepTimerOption {
  min15,
  min30,
  min45,
  hour1,
  endOfTrack,
  custom;

  int? get presetDurationMs {
    switch (this) {
      case SleepTimerOption.min15:
        return 15 * 60 * 1000;
      case SleepTimerOption.min30:
        return 30 * 60 * 1000;
      case SleepTimerOption.min45:
        return 45 * 60 * 1000;
      case SleepTimerOption.hour1:
        return 60 * 60 * 1000;
      case SleepTimerOption.endOfTrack:
      case SleepTimerOption.custom:
        return null;
    }
  }
}

class SleepTimerState {
  const SleepTimerState({
    this.active = false,
    this.stopAtEndOfTrack = false,
    this.endsAtEpochMs,
    this.option,
  });

  final bool active;
  final bool stopAtEndOfTrack;
  final int? endsAtEpochMs;
  final SleepTimerOption? option;

  static const idle = SleepTimerState();
}
