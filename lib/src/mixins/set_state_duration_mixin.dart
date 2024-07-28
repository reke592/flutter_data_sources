import 'dart:async';

import 'package:flutter/widgets.dart';

/// This [State] mixin use [Future.delayed] to delay a set state method call.
/// - [setStateAfterMillis]
/// - [setStateAfterSec]
/// - [setStateAfterDuration]
mixin SetStateDurationMixin<T extends StatefulWidget> on State<T> {
  void setStateAfterMillis(int milliseconds, void Function() nextState) {
    setStateAfterDuration(nextState, milliseconds: milliseconds);
  }

  void setStateAfterSec(int seconds, void Function() nextState) {
    setStateAfterDuration(nextState, seconds: seconds);
  }

  void setStateAfterDuration(
    void Function() nextState, {
    int seconds = 0,
    int milliseconds = 0,
  }) {
    Future.delayed(Duration(seconds: seconds, milliseconds: milliseconds), () {
      if (mounted) {
        setState(nextState);
      }
    });
  }
}
