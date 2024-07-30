import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_data_sources/flutter_data_sources.dart';

void main() {
  const responseDelayMS = 100;
  const defaultListInt = <int>[];
  const defaultListString = <String>[];
  const defaultListObject = <Map<String, dynamic>>[];
  final jsonListInt = jsonEncode([1, 2, 3]);
  final jsonListString = jsonEncode(['a', 'b', 'c']);
  final jsonListObject = jsonEncode([
    {"name": "erric", "lastname": "rapsing"},
    {"name": "john", "lastname": "doe"},
  ]);

  List<int> mapper1(dynamic value) {
    return List<int>.from(jsonDecode(value));
  }

  List<String> mapper2(dynamic value) {
    return List<String>.from(jsonDecode(value));
  }

  List<Map<String, dynamic>> mapper3(dynamic value) {
    return List<Map<String, dynamic>>.from(jsonDecode(value));
  }

  late DataRepository sut;
  late List<DataSource> sources;
  setUp(() {
    sources = [
      DataSource<List<int>>(
        name: 'list of int',
        request: (param, cancellation) => Future.value(jsonListInt),
        defaultValue: defaultListInt,
        id: (param) => '${param?.id ?? ''}',
        mapper: mapper1,
      ),
      DataSource<List<String>>(
        name: 'list of string',
        request: (param, cancellation) => Future.value(jsonListString),
        defaultValue: defaultListString,
        id: (param) => '${param?.id ?? ''}',
        mapper: mapper2,
      ),
      DataSource<List<Map<String, dynamic>>>(
        name: 'list of object',
        request: (param, cancellation) => Future.value(jsonListObject),
        defaultValue: defaultListObject,
        id: (param) => '${param?.id ?? ''}',
        mapper: mapper3,
      ),
      DataSource<List<int>>(
        name: 'list of int delayed',
        request: (param, cancellation) async {
          await Future.delayed(const Duration(milliseconds: responseDelayMS));
          return jsonListInt;
        },
        defaultValue: defaultListInt,
        id: (param) => '${param?.id ?? ''}',
        mapper: mapper1,
        logging: true,
        rememberError: true,
      ),
      DataSource<List<int>>(
        name: 'list of int delayed remember error false',
        request: (param, cancellation) async {
          await Future.delayed(const Duration(milliseconds: responseDelayMS));
          return jsonListInt;
        },
        defaultValue: defaultListInt,
        id: (param) => '${param?.id ?? ''}',
        mapper: mapper1,
        logging: true,
      ),
    ];
    sut = DataRepository(sources, logging: true);
  });

  tearDown(() {
    sut.dispose();
  });

  test(
    'calling unregistered DataStream should throw an error',
    () async {
      expect(() => sut.request('missing definition'), throwsException);
    },
  );

  test(
    'when repository has been disposed, all streams should close.',
    () async {
      await sut.dispose();
      expect(sut.sources.any((element) => !element.isClosed), false);
    },
  );

  test('when stream is initialized, it should have a default value', () async {
    var s1 = sut.on('list of int');
    var s2 = sut.on('list of string');
    var s3 = sut.on('list of object');
    expect(s1, emits(equals(defaultListInt)));
    expect(s2, emits(equals(defaultListString)));
    expect(s3, emits(equals(defaultListObject)));
  });

  test('on data request, it should map to correct type', () async {
    var s1 = sut.on('list of int');
    var s2 = sut.on('list of string');
    var s3 = sut.on('list of object');
    sut.request('list of int');
    sut.request('list of string');
    sut.request('list of object');
    expect(s1, emits(isA<List<int>>()));
    expect(s2, emits(isA<List<String>>()));
    expect(s3, emits(isA<List<Map<String, dynamic>>>()));
  });

  test('on clear data, it should reset the stream value to null', () async {
    var s1 = sut.on('list of int');
    var s2 = sut.on('list of string');
    var s3 = sut.on('list of object');
    sut.request('list of int');
    sut.request('list of string');
    sut.request('list of object');
    sut.clearAllData();
    expect(
      s1,
      emitsInOrder([
        defaultListInt,
        isA<List<int>>(),
        defaultListInt,
      ]),
    );
    expect(
      s2,
      emitsInOrder([
        defaultListString,
        isA<List<String>>(),
        defaultListString,
      ]),
    );
    expect(
      s3,
      emitsInOrder([
        defaultListObject,
        isA<List<Map<String, dynamic>>>(),
        defaultListObject,
      ]),
    );
  });

  test(
      'on cancellation of request, it should NOT add the request result in stream',
      () async {
    const resource = 'list of int delayed';
    List events = [];
    var s1 = sut.listen(
      'test',
      resource,
      onData: (data) => events.add(data),
      onError: (error, stack) => events.add(error),
    );
    var token = CancellationToken();
    sut.request(resource, cancellationToken: token);
    // wait for half duration of response delay
    await Future.delayed(
      const Duration(milliseconds: responseDelayMS ~/ 2),
      token.cancel,
    );
    await Future.delayed(const Duration(milliseconds: responseDelayMS + 100));
    expect(
      events,
      equals([
        defaultListInt, // initial
        isA<Exception>(),
      ]),
    );
    s1.cancel();
  });

  test(
      '''on cancellation of a request, and when [DataSource] remember error is false,
      it should always add the previous successful data so the [BehaviorStream] snapshot always has readable data.''',
      () async {
    const resource = 'list of int delayed remember error false';
    List events = [];
    var s1 = sut.listen(
      'test',
      resource,
      onData: (data) => events.add(data),
      onError: (error, stack) => events.add(error),
    );
    var token = CancellationToken();
    sut.request(
      resource,
      cancellationToken: token,
    );
    // wait for half duration of response delay
    await Future.delayed(
      const Duration(milliseconds: responseDelayMS ~/ 2),
      token.cancel,
    );
    await Future.delayed(const Duration(milliseconds: responseDelayMS + 100));
    expect(
      events,
      equals([
        defaultListInt, // initial
        isA<Exception>(),
        defaultListInt,
      ]),
    );
    s1.cancel();
  });
}
