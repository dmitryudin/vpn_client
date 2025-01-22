import 'package:shared_preferences/shared_preferences.dart';

class AppLocalization {
  static const String LANGUAGE_CODE = 'languageCode';
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'adblock': 'AdBlock',
      'kill_switch': 'Kill Switch',
      'kill_switch_description': 'Data leak protection when VPN disconnects',
      'off': 'Off',
      'Choose_server': 'Choose server',
      'connection': 'Connection',
      'on': 'On',
    },
    'ru': {
      'settings': 'Настройки',
      'language': 'Язык',
      'adblock': 'Блокировка рекламы',
      'kill_switch': 'Kill Switch',
      'kill_switch_description': 'Защита от утечки данных при обрыве VPN',
      'off': 'Отключено',
      'Choose_server': 'Выберите сервер',
      'connection': 'Подключение',
      'on': 'подключено',
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
