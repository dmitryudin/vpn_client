import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/localization/app_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vpn/ui/theme/app_theme.dart';
import 'package:vpn/utils/bloc/screen_state_bloc.dart';
import 'package:vpn/utils/vpn_bloc/vpn_bloc.dart';

import 'ui/routes /app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String languageCode =
      prefs.getString(AppLocalization.LANGUAGE_CODE) ?? 'ru';
  final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

  final router = await AppRouter.initialize();
  GetIt.I.registerSingleton<AuthService>(AuthService());

  GetIt.I<AuthService>().user = await GetIt.I<AuthService>().getUser();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<ScreenStateBloc>(
          lazy: false,
          create: (context) {
            ScreenStateBloc screenStateBloc = ScreenStateBloc();
            screenStateBloc.add(LoadServerList());
            return screenStateBloc;
          }),
      BlocProvider<VpnBloc>(
        create: (context) => VpnBloc(),
      ),
    ],
    child: Phoenix(
      child: MyApp(
        initialLanguage: languageCode,
        initialRoute: seenOnboarding ? '/' : '/onboarding',
        router: router,
      ),
    ),
  ));
}

class MyApp extends StatefulWidget {
  final String initialLanguage;
  final String initialRoute;
  final router;

  MyApp({
    super.key,
    required this.initialLanguage,
    required this.initialRoute,
    required this.router,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: widget.router,
      locale: Locale(widget.initialLanguage),
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
