import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:vpn/screens/home_screen.dart';

import '../screens/profile_drawer_screens/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
              child: SettingsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Увеличиваем длительность анимации до 1 секунды
                final tween = Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).chain(CurveTween(
                    curve:
                        Curves.easeInOut)); // Добавляем плавную кривую анимации

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            )),
  ],
);
