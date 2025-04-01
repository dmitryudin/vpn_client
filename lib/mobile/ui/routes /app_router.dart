// lib/routes/app_router.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/mobile/ui/screens/drawers/balance/balance_drawer_screens/change_tariff_screen.dart';
import 'package:vpn/mobile/ui/screens/help_screens/without_add.dart';

import '../screens/auth_screens/auth_screen.dart';
import '../screens/drawers/balance/balance_drawer_screens/invite_friend_screen.dart';
import '../screens/drawers/profile/profile_drawer_screens/about_screen.dart';
import '../screens/drawers/profile/profile_drawer_screens/faq_screen.dart';
import '../screens/drawers/profile/profile_drawer_screens/support_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screens/onboarding_screen.dart';
import '../screens/drawers/profile/profile_drawer_screens/settings_screen.dart';

class AppRouter {
  static late String _initialRoute;

  static Future<GoRouter> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _initialRoute =
        prefs.getBool('seen_onboarding') ?? false ? '/' : '/onboarding';

    return GoRouter(
      initialLocation: _initialRoute,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => OnboardingScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => AuthScreen(),
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: AboutScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/faq',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: FAQScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/support',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: SupportScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: SettingsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/tariff',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: ChangeTariffScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/invite',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: InviteFriendScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/withoutAdd',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: WithoutAdd(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
      ],
    );
  }
}
