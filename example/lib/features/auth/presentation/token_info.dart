import 'package:flutter_data_sources/flutter_data_sources.dart';
import 'package:flutter/material.dart';
import 'package:example/repository.dart';
import 'package:example/features/auth/domain/session.dart';

class TokenInfo extends StatefulWidget {
  const TokenInfo({super.key});

  @override
  State<TokenInfo> createState() => _TokenInfoState();
}

class _TokenInfoState extends State<TokenInfo> with DataSubscriptionStateMixin {
  Session? _session;

  void _handleData(Session data) {
    setState(() {
      _session = data;
    });
  }

  @override
  Subs initSubscriptions() {
    return [
      repo.listen<Session>(this, 'login', onData: _handleData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Text(_session.toString());
  }
}
