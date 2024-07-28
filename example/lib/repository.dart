import 'package:flutter_data_sources/flutter_data_sources.dart';
import 'package:example/features/auth/data/auth_data_source.dart';
import 'package:example/features/profile/data/profile_data_sources.dart';

final repo = DataRepository(
  [
    ...authDataSource,
    ...profileDataSource,
  ],
  logging: true,
);
