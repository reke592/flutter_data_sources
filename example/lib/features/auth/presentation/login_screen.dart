import 'package:flutter_data_sources/flutter_data_sources.dart';
import 'package:flutter/material.dart';
import 'package:example/features/auth/domain/session.dart';
import 'package:example/features/auth/presentation/token_info.dart';
import 'package:example/router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.repo,
  });

  final DataRepository repo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with DataSubscriptionStateMixin, SetStateDurationMixin {
  String _username = '';
  String _password = '';
  bool _displaySessionInfo = false;
  Object? lastError;
  int cancelledAttempts = 0;

  @override
  Subs initSubscriptions() {
    return [
      widget.repo.listen<Session>(
        this,
        'login',
        onData: _handleLoginResult,
        onError: _handleLoginError,
      ),
    ];
  }

  void _handleLogin() {
    widget.repo.request(
      'login',
      param: {
        'username': _username,
        'password': _password,
      },
      cancelPrevious: true,
    );
  }

  void _handleUsernameChanged(String value) {
    _username = value;
  }

  void _handlePasswordChanged(String value) {
    _password = value;
  }

  void _handleLoginResult(Session value) {
    if (value.isValid) {
      debugPrint(value.toString());
      router.pushReplacementNamed('profile');
    }
  }

  void _handleLoginError(Object error, StackTrace stack) {
    if (error is CancellationTokenException) {
      cancelledAttempts++;
    }
    setStateAfterMillis(100, () {
      lastError = 'Login failed. $error';
    });
  }

  void _handleSessionInfoVisibility(bool value) {
    setState(() {
      _displaySessionInfo = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Wrap(
            spacing: 8,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              Text(
                'Example Login',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'user: admin, pass: admin',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              TextField(
                onChanged: _handleUsernameChanged,
              ),
              TextField(
                onChanged: _handlePasswordChanged,
                obscureText: true,
              ),
              if (lastError != null)
                Text(
                  '$lastError',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                      ),
                ),
              if (cancelledAttempts > 0)
                Text(
                  '$cancelledAttempts cancelled attempts',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                      ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Sign-up'),
                  ),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Signin'),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Display Token Info:'),
                  Switch(
                    value: _displaySessionInfo,
                    onChanged: _handleSessionInfoVisibility,
                  ),
                ],
              ),
              if (_displaySessionInfo) ...[
                const Divider(),
                const TokenInfo(),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
