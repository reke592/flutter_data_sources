import 'package:flutter_data_sources/flutter_data_sources.dart';
import 'package:flutter/material.dart';
import 'package:example/features/profile/domain/profile.dart';
import 'package:example/widgets/logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.repo,
  });

  final DataRepository repo;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with DataSubscriptionStateMixin {
  Profile? _profile;

  void _handleProfileData(Profile data) {
    if (data != Profile.empty) {
      setState(() {
        _profile = data;
      });
    }
  }

  @override
  Subs initSubscriptions() {
    return [
      widget.repo.listen<Profile>(
        this,
        'profile',
        onData: _handleProfileData,
      ),
    ];
  }

  @override
  void initState() {
    widget.repo.request('profile');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.repo.isWaiting('profile'))
              const CircularProgressIndicator(),
            if (_profile != null) ...[
              welcome(_profile!),
              const LogoutButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget welcome(Profile profile) {
    return Center(
      child: Text('Hello ${profile.name}!'),
    );
  }
}
