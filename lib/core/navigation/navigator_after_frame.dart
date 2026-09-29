import 'dart:async';

import 'package:flutter/scheduler.dart';

/// Runs [action] after the current frame — Navigator must not push/pop during a gesture.
Future<T?> runNavigatorActionAfterFrame<T>(FutureOr<T?> Function() action) {
  final completer = Completer<T?>();
  SchedulerBinding.instance.addPostFrameCallback((_) async {
    try {
      completer.complete(await action());
    } catch (e, st) {
      if (!completer.isCompleted) {
        completer.completeError(e, st);
      }
    }
  });
  return completer.future;
}
