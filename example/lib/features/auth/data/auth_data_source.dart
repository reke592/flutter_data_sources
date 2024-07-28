import 'dart:developer';

import 'package:flutter_data_sources/flutter_data_sources.dart';
import 'package:example/features/auth/domain/session.dart';

final authDataSource = [
  DataSource<Session>(
    name: 'login',
    request: (params, cToken) async {
      cToken.onCancel(() {
        log('TODO: HTTP client stream.close()');
      });
      await Future.delayed(const Duration(seconds: 2));
      if (params['username'] == 'admin' && params['password'] == 'admin') {
        return const Session(token: 'sample', refreshToken: null).asJson();
      } else {
        throw 'Invalid usrename or password';
      }
    },
    mapper: (value) => Session.fromJson(value),
    defaultValue: Session.empty,
  ),
  DataSource<bool?>(
    name: 'logout',
    request: (_, cToken) async {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    },
    mapper: (data) => data,
    defaultValue: null,
    logging: true,
  ),
];
