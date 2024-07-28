import 'dart:async';
import 'dart:developer';

import 'package:flutter_data_sources/flutter_data_sources.dart';

/// {@template DataRepository}
/// Repository for [DataSource] streams. handles automatic cancellation of subsequent request with same parameters.
///
/// TODO: offline storage to restore the last successful value of [DataSource] for offline-use.
///
/// see also:
/// [DataSubscriptionStateMixin]
/// [SetStateDurationMixin]
/// {@endtemplate}
class DataRepository {
  /// {@macro DataRepository}
  DataRepository(List<DataSource> sources, {this.logging = false}) {
    for (var source in sources) {
      if (_config.containsKey(source.name)) {
        throw Exception('Duplicate data source registration: ${source.name}');
      }
      _config[source.name] = source;
    }
  }

  final Map<String, CancellationToken> _waiting = {};
  final Map<String, DataSource> _config = {};

  /// list of registered [DataSource]
  Iterable<DataSource> get sources => _config.values;

  /// display dev logs
  final bool logging;

  void _log(String message) {
    if (!logging) return;
    log('DataRepository: $message');
  }

  /// TODO: save to local storage
  void _saveToDB(DataSource source, dynamic param, dynamic data) async {
    if (source.availableOffline) {
      _log('TODO: _saveToDB, ${source.name}');
    }
  }

  /// close all [DataSource] stream
  Future<void> dispose() async {
    for (var source in _config.values) {
      await source.close();
    }
  }

  /// awaits all request then reset all [DataSource] stream value to default.
  Future<void> clearAllData() async {
    if (_waiting.isNotEmpty) {
      _log('clearAllData, waiting for ${_waiting.length} remaining request.');
      await Future.delayed(const Duration(seconds: 1));
      return clearAllData();
    }
    for (var source in _config.values) {
      source.reset();
    }
  }

  /// creates a new [StreamSubscription] to [DataSource] identified by [requestName]
  ///
  /// setting [ingoreError] to true will ignore the [onError] and assign a noop method to ignore emitted errors.
  StreamSubscription<T> listen<T>(
    Object listenerName,
    String dataSourceName, {
    void Function(T)? onData,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return on<T>(dataSourceName).listen(
      onData,
      onError: (error, stackTrace) {
        _log(
          '[${error.runtimeType}] on $dataSourceName\n'
          '${onError == null ? 'ignored' : 'handled'} in $listenerName.',
        );
        onError?.call(error, stackTrace);
      },
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// returns a [Stream] of [DataSource] identified by [name] as BroadcastStream.
  Stream<T> on<T>(String name) {
    if (_config[name] != null) {
      var source = _config[name] as DataSource<T>;
      var broadcast = source.asBroadcastStream();
      return broadcast;
    } else {
      throw Exception('missing DataStream definition: "$name"');
    }
  }

  /// use [DataSource] request and emit the result to stream.
  ///
  /// [cancelPrevious] true will trigger cancellation token.
  ///
  /// [repeatable] true will ignore waiting request, resulting to double emit.
  ///
  /// [cancellationToken] optional, to let the UI control the cancellation of request.
  void request<T>(
    String name, {
    dynamic param,
    bool cancelPrevious = false,
    CancellationToken? cancellationToken,
  }) {
    if (_config[name] != null) {
      var source = _config[name] as DataSource;
      source.init();

      final streamKey = source.key(param);
      final waiting = _waiting[streamKey] != null;
      if (waiting && !cancelPrevious) {
        _log('previous $name request is still loading.');
        return;
      } else if (waiting && cancelPrevious) {
        _log('cancelling previous $name request');
        // make sure to catch any thrown error onCancel
        // so it won't affect the new request call
        try {
          _waiting[streamKey]?.cancel();
        } catch (error, stackTrace) {
          source.emitError(error, stackTrace);
        }
      }
      // assign new cancellation
      var cToken = cancellationToken ?? CancellationToken();
      _waiting[streamKey] = cToken;
      _log('sending request $name.');
      // here we don't use the _waiting[streamKey] value because it will be overridden
      // on subsequent request method call.
      _makeRequest(source, param, cToken)
          .then((data) => source.emitMapped(data))
          .then((data) => _saveToDB(source, param, data))
          .onError(source.emitError)
          .whenComplete(() => clearWaiting(streamKey, !cToken.isCancelled));
    } else {
      throw Exception('missing DataStream definition: "$name"');
    }
  }

  /// awaits [DataSource.request] finally calls [cToken.verify] to finalize the emit process.
  Future<R> _makeRequest<R>(
    DataSource<R> source,
    dynamic param,
    CancellationToken cToken,
  ) async {
    try {
      return await source.request(param, cToken);
    } catch (_) {
      rethrow;
    } finally {
      cToken.verify();
    }
  }

  /// checks wheter the [DataSource] is awaiting response
  bool isWaiting(String name, [dynamic param]) {
    var source = _config[name] as DataSource;
    var streamKey = source.key(param);
    return _waiting[streamKey] != null;
  }

  /// removes the waiting key for a [DataSource] in [DataRepository].
  ///
  /// this will make the new [request] to re-send and will result to double emit.
  void clearWaiting(String key, [bool clear = true]) {
    // check flag, when cancellation token isCancelled
    if (clear) {
      _log('clearWaiting($key)');
      _waiting.remove(key);
    }
  }
}
