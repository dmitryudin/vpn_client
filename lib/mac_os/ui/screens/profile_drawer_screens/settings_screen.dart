import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/localization/app_localization.dart';

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
            ],
          ),
        ),
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
            ElevatedButton(onPressed: () {}, child: Text('Выйти из профиля')),
            SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: Text('Удалить аккаунт'))
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
