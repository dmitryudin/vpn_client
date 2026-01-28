import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Сервис для хранения и получения статистики VPN
class VpnStatisticsService {
  static const String _keySessionStart = 'vpn_session_start';
  static const String _keyDailyStats = 'vpn_daily_stats';
  static const String _keyTotalData = 'vpn_total_data';
  static const String _keyTotalTime = 'vpn_total_time';
  static const String _keyConnectionsCount = 'vpn_connections_count';

  /// Сохранить время начала сессии
  static Future<void> saveSessionStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySessionStart, DateTime.now().millisecondsSinceEpoch);
  }

  /// Получить длительность текущей сессии
  static Future<Duration> getSessionDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionStart = prefs.getInt(_keySessionStart);
    if (sessionStart == null) {
      return Duration.zero;
    }
    final startTime = DateTime.fromMillisecondsSinceEpoch(sessionStart);
    return DateTime.now().difference(startTime);
  }

  /// Очистить время начала сессии
  static Future<void> clearSessionStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionStart);
  }

  /// Получить статистику за сегодня
  static Future<Map<String, dynamic>> getDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final dailyStatsJson = prefs.getString('$_keyDailyStats$today');
    
    if (dailyStatsJson != null) {
      return jsonDecode(dailyStatsJson) as Map<String, dynamic>;
    }
    
    return {
      'date': today,
      'duration': 0, // в секундах
      'dataTransferred': 0, // в байтах
      'connectionsCount': 0,
    };
  }

  /// Обновить статистику за сегодня
  static Future<void> updateDailyStats({
    int? durationSeconds,
    int? dataBytes,
    int? connectionsCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final currentStats = await getDailyStats();
    
    currentStats['duration'] = (currentStats['duration'] as int) + (durationSeconds ?? 0);
    currentStats['dataTransferred'] = (currentStats['dataTransferred'] as int) + (dataBytes ?? 0);
    if (connectionsCount != null) {
      currentStats['connectionsCount'] = connectionsCount;
    } else {
      currentStats['connectionsCount'] = (currentStats['connectionsCount'] as int) + 1;
    }
    
    await prefs.setString('$_keyDailyStats$today', jsonEncode(currentStats));
  }

  /// Получить статистику за неделю
  static Future<Map<String, dynamic>> getWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    int totalDuration = 0;
    int totalData = 0;
    int totalConnections = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final dailyStatsJson = prefs.getString('$_keyDailyStats$dateStr');
      
      if (dailyStatsJson != null) {
        final stats = jsonDecode(dailyStatsJson) as Map<String, dynamic>;
        totalDuration += stats['duration'] as int;
        totalData += stats['dataTransferred'] as int;
        totalConnections += stats['connectionsCount'] as int;
      }
    }
    
    return {
      'duration': totalDuration,
      'dataTransferred': totalData,
      'connectionsCount': totalConnections,
    };
  }

  /// Симуляция передачи данных на основе времени подключения
  /// Примерно 1 MB в минуту (реалистичная скорость для VPN)
  static int estimateDataTransferred(Duration duration) {
    // Примерно 1 MB в минуту = ~17 KB в секунду
    final bytesPerSecond = 17 * 1024; // 17 KB/сек
    return (duration.inSeconds * bytesPerSecond).toInt();
  }

  /// Сохранить общую статистику
  static Future<void> saveTotalStats({
    required int durationSeconds,
    required int dataBytes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTotalTime = prefs.getInt(_keyTotalTime) ?? 0;
    final currentTotalData = prefs.getInt(_keyTotalData) ?? 0;
    
    await prefs.setInt(_keyTotalTime, currentTotalTime + durationSeconds);
    await prefs.setInt(_keyTotalData, currentTotalData + dataBytes);
  }

  /// Увеличить счетчик подключений
  static Future<void> incrementConnectionsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_keyConnectionsCount) ?? 0;
    await prefs.setInt(_keyConnectionsCount, currentCount + 1);
  }

  /// Получить общее количество подключений
  static Future<int> getTotalConnectionsCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyConnectionsCount) ?? 0;
  }

  /// Форматировать байты в читаемый формат
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Форматировать секунды в читаемый формат
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '$hours ч $minutes мин';
    }
    if (minutes > 0) {
      return '$minutes мин $secs сек';
    }
    return '$secs сек';
  }
}
