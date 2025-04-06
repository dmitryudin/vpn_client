import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/localization/app_localization.dart';
import 'package:vpn/main.dart';

import 'package:vpn/mobile/utils/bloc/screen_state_bloc.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool adBlockEnabled = false;
  bool isExpanded = false;
  bool killSwitchEnabled = false;
  bool isDarkMode = false;
  String selectedLanguage = 'Русский';
  final List<String> languages = ['Русский', 'English'];

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
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
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

  void _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
    Phoenix.rebirth(context);
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
        leading: IconButton(
          icon: AnimatedRotation(
            duration: Duration(milliseconds: 300),
            turns: isExpanded ? 0.5 : 0,
            child: Icon(Icons.keyboard_arrow_down_outlined,
                color: colorScheme.onPrimary),
          ),
          onPressed: () {
            setState(() {
              isExpanded = !isExpanded;
            });
            context.pop();
          },
        ),
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSettingsCard(
              AppLocalization.translate('language', 'ru'),
              DropdownButton<String>(
                value: selectedLanguage,
                items: languages.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: _changeLanguage,
              ),
            ),
            SizedBox(height: 16),
            _buildSwitchCard(
              'Темная тема',
              'Переключить светлую/темную тему',
              isDarkMode,
              _toggleTheme,
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

  Widget _buildSettingsCard(String title, Widget trailing) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            )),
        trailing: trailing,
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
