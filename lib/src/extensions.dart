import 'dart:async';

extension SubsCancel on List<StreamSubscription> {
  /// cancel all [StreamSubscription]
  void cancel() {
    for (var e in this) {
      e.cancel();
    }
    clear();
  }
}
