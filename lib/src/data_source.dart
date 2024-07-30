import 'dart:async';
import 'dart:developer';

import 'package:flutter_data_sources/flutter_data_sources.dart';
import 'package:flutter_data_sources/src/logger.dart';
import 'package:rxdart/rxdart.dart';

/// {@template DataSource}
/// A [DataSource] is a configuration object for specific data / api-endpoint.
/// it has a [BehaviorSubject] stream to remember the response and isolate the listeners.
///
/// The stream will only get initialized when using the any of the following method.
/// - [DataRepository.on]
/// - [DataRepository.listen]
/// - [DataRepository.request]
///
/// The [defaultValue] is required on stream [init] or [reset].
///
/// The [reset] can be triggered manually or when using [DataRepository.clearAllData]
/// {@endtemplate}
class DataSource<T> {
  /// {@macro DataSource}
  DataSource({
    required this.name,
    required this.request,
    required this.mapper,
    required this.defaultValue,
    this.availableOffline = false,
    this.rememberError = false,
    this.logging = false,
    this.id,
  });

  /// display dev logs
  final bool logging;

  /// unique name for this resource request.
  final String name;

  /// asynchronous request to submit.
  ///
  /// the result is intended to be dynamic because the [mapper] contains the logic how to read a model from any form of data.
  final Future<dynamic> Function(dynamic param, CancellationToken cToken)
      request;

  /// mapper function for successful response.
  final T Function(dynamic param) mapper;

  /// a default value to assign on stream [init] or [reset].
  final T defaultValue;

  /// TODO: if enabled, successful response will be stored for offline use.
  final bool availableOffline;

  /// if enabled, the [BehaviorSubject] will remember the error event, new subscriptions will automatically receive the error.
  ///
  /// if disabled, the [emitError] will always add the previous successful data after emitting an error object,
  /// this makes the [BehaviorSubject] stream consistent to always have a readable data.
  final bool rememberError;

  /// unique identity based on request parameter to properly return the ofline data.
  final String Function(dynamic param)? id;

  BehaviorSubject<T>? _stream;

  /// unique key used in DataRepository Set of waiting to debounce multiple request with the same parameter.
  String key(dynamic param) => '$name@${id?.call(param) ?? ''}';

  void _log(String message) {
    if (!logging) return;
    log('${toString()}: $message');
  }

  /// a broadcast stream for subscription. MUST cancel the subscription if not needed anymore.
  ///
  /// calls [init] if the stream is not yet initialized
  Stream<T> asBroadcastStream() {
    if (!isInitialized) init();
    return _stream!.asBroadcastStream(
      onListen: (sub) {
        _log('subscription created');
      },
      onCancel: (sub) {
        _log('subscription cancelled');
      },
    );
  }

  /// check if the [BehaviorSubject] stream is closed.
  bool get isClosed => _stream?.isClosed ?? true;

  /// check if the [BehaviorSubject] stream is already initialized.
  bool get isInitialized => _stream != null;

  /// set the [BehaviorSubject] stream if not yet initialized
  ///
  /// TODO: load from storage if this [DataSource] is available for offline use.
  void init() {
    if (isInitialized) return;
    _log('init');
    _stream = BehaviorSubject<T>()..add(defaultValue);
  }

  /// close the [BehaviorSubject] stream
  Future<void> close() async {
    _log('close');
    await _stream?.close();
  }

  /// reset the current value of [BehaviorSubject] to [defaultValue] without closing the stream.
  Future<void> reset() async {
    _log('reset');
    _stream?.value = defaultValue;
    await _stream?.done;
  }

  /// map and emit data to stream
  FutureOr<R> emitMapped<R>(R data) {
    _stream!.add(mapper(data));
    return data;
  }

  /// emit error to stream
  void emitError(Object error, [StackTrace? stackTrace]) {
    if (error is! CancellationTokenException) {
      logger.e('${toString()}: $error', stackTrace: stackTrace);
    }
    var previous = _stream!.value;
    _stream!.addError(error, stackTrace);
    if (!rememberError) {
      _stream!.add(previous);
    }
  }

  @override
  String toString() => '$runtimeType[$name]';
}
