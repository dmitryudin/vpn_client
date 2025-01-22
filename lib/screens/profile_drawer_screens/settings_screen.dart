import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/localization/app_localization.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool adBlockEnabled = false;
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
      setState(() {
        selectedLanguage = newLanguage;
      });
      String languageCode = newLanguage == 'English' ? 'en' : 'ru';
      await AppLocalization.setLanguage(languageCode);
      Phoenix.rebirth(
          context); // Перезапуск приложения для применения изменений
    }
  }

  void _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
    Phoenix.rebirth(context); // Перезагружаем приложение для применения темы
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Настройки',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Color(0xFF1E3A5F),
        leading: IconButton(
          icon: Icon(Icons.arrow_downward, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A5F),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSettingsCard(
              'Язык',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(String title, Widget trailing) {
    return Card(
      elevation: 4,
      color: Color(0xFF344966),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        trailing: trailing,
      ),
    );
  }

  Widget _buildSwitchCard(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Card(
      elevation: 4,
      color: Color(0xFF344966),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        subtitle: Text(subtitle,
            style: TextStyle(
              color: Colors.white70,
            )),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
