import 'package:flutter_data_sources/src/errors/cancellation_token_exception.dart';

/// a cancellation token used to cancel a waiting [DataRepository] request.
///
/// ```dart
/// // e.g.
/// var cancel = repo.request('login', params);
/// cancel();
/// ```
class CancellationToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  void Function()? _onCancel;

  /// a callback to run when the token is cancelled.
  void onCancel(void Function() cb) {
    _onCancel = cb;
  }

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    _onCancel?.call();
  }

  /// verify if token is cancelled.
  ///
  /// throws: [CancellationTokenException] with the provided message.
  void verify([String message = '']) {
    if (_isCancelled) {
      throw CancellationTokenException(message);
    }
  }
}
