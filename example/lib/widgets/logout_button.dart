import 'package:flutter/material.dart';
import 'package:example/repository.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        repo.request('logout', cancelPrevious: true);
      },
      child: const Text('Signout'),
    );
  }
}
