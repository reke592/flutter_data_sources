import 'package:flutter_data_sources/flutter_data_sources.dart';
import 'package:example/features/profile/domain/profile.dart';

final profileDataSource = [
  DataSource<Profile>(
    name: 'profile',
    request: (params, cToken) async {
      await Future.delayed(const Duration(seconds: 1));
      return const Profile(name: 'admin').asJson();
    },
    mapper: (value) => Profile.fromJson(value),
    defaultValue: Profile.empty,
    availableOffline: true,
    logging: true,
  ),
];
