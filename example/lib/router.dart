import 'package:example/features/auth/presentation/login_screen.dart';
import 'package:example/features/profile/presentation/profile_screen.dart';
import 'package:example/repository.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginScreen(repo: repo),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => ProfileScreen(repo: repo),
    ),
  ],
);
