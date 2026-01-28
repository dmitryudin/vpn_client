import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/localization/app_localization.dart';
import 'package:vpn/mobile/ui/widgets/enhanced_dropdown.dart';
import 'package:vpn/mobile/ui/widgets/animated_card.dart';
import 'package:vpn/mobile/ui/widgets/animated_back_button.dart';

import 'package:vpn/mobile/utils/bloc/screen_state_bloc.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool adBlockEnabled = false;
  bool killSwitchEnabled = false;
  String selectedThemeMode = 'Системная';
  String selectedLanguage = 'Русский';
  final List<String> languages = ['Русский', 'English'];
  final List<String> themeModes = ['Системная', 'Светлая', 'Тёмная'];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    _loadThemeMode();
  }

  void _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppLocalization.LANGUAGE_CODE) ?? 'ru';
    setState(() {
      selectedLanguage = languageCode == 'en' ? 'English' : 'Русский';
    });
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString('themeMode') ?? 'system';
    setState(() {
      if (savedThemeMode == 'light') {
        selectedThemeMode = 'Светлая';
      } else if (savedThemeMode == 'dark') {
        selectedThemeMode = 'Тёмная';
      } else {
        selectedThemeMode = 'Системная';
      }
    });
  }

  void _changeLanguage(String? newLanguage) async {
    if (newLanguage != null) {
      final prefs = await SharedPreferences.getInstance();
      String languageCode = newLanguage == 'English' ? 'en' : 'ru';
      // Сохраняем язык
      await prefs.setString(AppLocalization.LANGUAGE_CODE, languageCode);
      setState(() {
        selectedLanguage = newLanguage;
      });
      // Перезапускаем приложение
      if (mounted) {
        Phoenix.rebirth(context);
      }
    }
  }

  void _changeThemeMode(String? newThemeMode) async {
    if (newThemeMode != null) {
      final prefs = await SharedPreferences.getInstance();
      String themeModeValue;
      if (newThemeMode == 'Светлая') {
        themeModeValue = 'light';
      } else if (newThemeMode == 'Тёмная') {
        themeModeValue = 'dark';
      } else {
        themeModeValue = 'system';
      }
      
      await prefs.setString('themeMode', themeModeValue);
      setState(() {
        selectedThemeMode = newThemeMode;
      });
      // Перезапускаем приложение для применения темы
      if (mounted) {
        Phoenix.rebirth(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalization.translate('settings', 'ru'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        leading: AnimatedBackButton(
          iconColor: colorScheme.onPrimary,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.background,
              colorScheme.surfaceVariant,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AnimatedCard(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: EnhancedDropdown<String>(
                value: selectedLanguage,
                items: languages,
                itemBuilder: (item) => item,
                onChanged: _changeLanguage,
                label: AppLocalization.translate('language', 'ru'),
                icon: Icons.language_rounded,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedCard(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: EnhancedDropdown<String>(
                value: selectedThemeMode,
                items: themeModes,
                itemBuilder: (item) => item,
                onChanged: _changeThemeMode,
                label: 'Тема приложения',
                icon: Icons.palette_rounded,
              ),
            ),
            SizedBox(height: 16),
            _buildSwitchCard(
              'AdBlock',
              'Блокировка рекламы и трекеров',
              adBlockEnabled,
              (value) => setState(() => adBlockEnabled = value),
            ),
            SizedBox(height: 16),
            _buildSwitchCard(
              'Kill Switch',
              'Защита от утечки данных при обрыве VPN',
              killSwitchEnabled,
              (value) => setState(() => killSwitchEnabled = value),
            ),
            SizedBox(height: 16),
            GetIt.I<AuthService>().user.authStatus == AuthStatus.authorized
                ? Align(
                    child: ElevatedButton(
                        onPressed: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Подтверждение выхода'),
                                content: Text('Вы уверены, что хотите выйти?'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text('Отмена'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Закрываем диалог
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text('Да'),
                                    onPressed: () {
                                      // Здесь вы можете добавить логику для удаления аккаунта
                                      // Например, вызов API для удаления аккаунта
                                      // После удаления закрываем диалог
                                      Navigator.of(context).pop(true);
                                      // Можно также показать сообщение об успешном удалении
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirm == true) {
                            await BlocProvider.of<ScreenStateBloc>(context)
                                .logOut();

                            context.pop();
                          }
                        },
                        child: Text('Выйти из профиля')))
                : Container(),
            SizedBox(height: 16),
            GetIt.I<AuthService>().user.authStatus == AuthStatus.authorized
                ? Align(
                    child: ElevatedButton(
                        onPressed: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Подтверждение удаления'),
                                content: Text(
                                    'Вы уверены, что хотите удалить аккаунт?'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text('Отмена'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Закрываем диалог
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text('Удалить'),
                                    onPressed: () {
                                      // Здесь вы можете добавить логику для удаления аккаунта
                                      // Например, вызов API для удаления аккаунта
                                      // После удаления закрываем диалог
                                      Navigator.of(context).pop(true);
                                      // Можно также показать сообщение об успешном удалении
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirm == true) {
                            await BlocProvider.of<ScreenStateBloc>(context)
                                .logOut();
                            context.pop();
                          }
                        },
                        child: Text('Удалить аккаунт'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                        )))
                : Container()
          ],
        ),
      ),
    );
  }


  Widget _buildSwitchCard(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            )),
        subtitle: Text(subtitle,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
            )),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
