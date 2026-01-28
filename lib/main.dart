import 'dart:io';

import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_updater/updater_repository.dart';
import 'package:flutter_vpn/state.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart';
import 'package:vpn/localization/app_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vpn/mobile/internal.dart';
import 'package:vpn/mobile/ui/screens/updater_dialog/updater_dialog.dart';
import 'package:vpn/mobile/ui/theme/app_theme.dart';
import 'package:vpn/mobile/utils/bloc/screen_state_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_state.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import 'mobile/ui/routes /app_router.dart';

void checkUpdates(BuildContext context) {
  Updater updater = Updater(baseUrl: Config.baseUrl);
  Future<UpdateObject> updateObject = updater.checkUpdates();
  updateObject.then((UpdateObject object) {
    if (object.availibleUpdate) {
      showForceUpdateDialog(context, object.urlForUpdate);
    }
  });
}

Key key = UniqueKey();

void restartApp() {
  key = UniqueKey();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await MobileAds.initialize();
  final prefs = await SharedPreferences.getInstance();
  final String languageCode =
      prefs.getString(AppLocalization.LANGUAGE_CODE) ?? 'ru';
  final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

  final router = await AppRouter.initialize();
  GetIt.I.registerSingleton<AuthService>(AuthService());

  GetIt.I<AuthService>().user = await GetIt.I<AuthService>().getUser();
  print(await getDeviceInfo());
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
        key: key,
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
  final GoRouter router;

  MyApp({
    super.key,
    required this.initialLanguage,
    required this.initialRoute,
    required this.router,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  Brightness? _systemBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUpdates(context);
    });

    // Configure the user privacy data policy before init sdk
    MobileAds.initialize();

    // Получаем текущую системную яркость
    _systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    
    _loadThemeMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Обновляем системную яркость при изменении
    final newBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    
    if (_themeMode == ThemeMode.system) {
      setState(() {
        _systemBrightness = newBrightness;
        // Принудительно обновляем состояние для применения новой темы
      });
    }
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString('themeMode');

    setState(() {
      if (savedThemeMode == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedThemeMode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        // По умолчанию системная тема
        _themeMode = ThemeMode.system;
      }
    });
  }

  // Определяем эффективную тему с учетом системной яркости
  // Для iOS явно проверяем системную яркость, так как ThemeMode.system может работать некорректно
  ThemeMode get _effectiveThemeMode {
    if (_themeMode == ThemeMode.system) {
      // Всегда получаем актуальную системную яркость
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      // Обновляем кэшированное значение
      if (_systemBrightness != brightness) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _systemBrightness = brightness;
            });
          }
        });
      }
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    return _themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VpnBloc, VpnState>(
      listener: (context, state) {
        if (Platform.isMacOS) {
          switch (state.connectionState) {
            case FlutterVpnState.disconnected:
              SystemTray().setSystemTrayInfo(
                  title: 'Отключено', iconPath: 'assets/icons/pixel.png');
              break;
            case FlutterVpnState.connecting:
              SystemTray().setSystemTrayInfo(
                  title: 'Подключение', iconPath: 'assets/icons/image.gif');
              break;
            case FlutterVpnState.connected:
              SystemTray().setSystemTrayInfo(
                  title: 'Подключено', iconPath: 'assets/icons/connected.png');
              break;
            case FlutterVpnState.disconnecting:
              SystemTray().setSystemTrayInfo(
                  title: 'Отключено', iconPath: 'assets/icons/pixel.png');
              break;
            case FlutterVpnState.error:
              SystemTray().setSystemTrayInfo(
                  title: 'Ошибка', iconPath: 'assets/icons/pixel.png');
              break;
          }
        }
        // TODO: implement listener
      },
      child: MaterialApp.router(
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
        themeMode: _effectiveThemeMode,
      ),
    );
  }
}
