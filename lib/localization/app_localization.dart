import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalization {
  static AppLocalization? of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(LANGUAGE_CODE) ?? 'ru';
  }

  static const String LANGUAGE_CODE = 'languageCode';
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'dark_theme': 'Dark Theme',
      'dark_theme_description': 'Toggle light/dark theme',
      'adblock': 'AdBlock',
      'adblock_description': 'Block ads and trackers',
      'kill_switch': 'Kill Switch',
      'kill_switch_description': 'Data leak protection when VPN disconnects',
    },
    'ru': {
      'settings': 'Настройки',
      'language': 'Язык',
      'dark_theme': 'Темная тема',
      'dark_theme_description': 'Переключить светлую/темную тему',
      'adblock': 'Блокировка рекламы',
      'adblock_description': 'Блокировка рекламы и трекеров',
      'kill_switch': 'Kill Switch',
      'kill_switch_description': 'Защита от утечки данных при обрыве VPN',
    },
  };

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_CODE, languageCode);
  }

  static String translate(String key, String languageCode) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}
