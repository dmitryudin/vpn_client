import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/localization/app_localization.dart';
import 'package:vpn/routes%20/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vpn/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String languageCode =
      prefs.getString(AppLocalization.LANGUAGE_CODE) ?? 'ru';
  runApp(Phoenix(child: MyApp(initialLanguage: languageCode)));
}

class MyApp extends StatefulWidget {
  final String initialLanguage;

  MyApp({super.key, required this.initialLanguage});

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
      // Добавлен оператор return
      locale: Locale(widget.initialLanguage),
      supportedLocales: [
        Locale('en'),
        Locale('ru'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
