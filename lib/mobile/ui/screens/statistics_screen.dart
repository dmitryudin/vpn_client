import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_state.dart';
import 'package:vpn/mobile/utils/vpn_statistics_service.dart';
import 'package:vpn/mobile/utils/bloc/screen_state_bloc.dart';
import 'package:vpn/mobile/ui/widgets/fade_in_widget.dart';
import 'package:vpn/mobile/ui/widgets/animated_back_button.dart';
import 'package:flutter_vpn/state.dart';

/// Экран статистики использования VPN
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _updateTimer;
  Duration _sessionDuration = Duration.zero;
  Map<String, dynamic> _dailyStats = {};
  Map<String, dynamic> _weeklyStats = {};
  bool _isVpnConnected = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    _checkInitialVpnState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadStatistics();
        _startUpdateTimer();
      }
    });
  }

  void _checkInitialVpnState() {
    // Проверяем начальное состояние VPN через BlocBuilder
    // Не используем context.read здесь, так как он может быть недоступен
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vpnBloc = context.read<VpnBloc>();
        final isConnected =
            vpnBloc.state.connectionState == FlutterVpnState.connected;
        setState(() {
          _isVpnConnected = isConnected;
        });
        if (isConnected) {
          // Если VPN уже подключен, загружаем время сессии
          VpnStatisticsService.getSessionDuration().then((duration) {
            if (mounted) {
              setState(() {
                _sessionDuration = duration;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final sessionDuration = await VpnStatisticsService.getSessionDuration();
    final dailyStats = await VpnStatisticsService.getDailyStats();
    final weeklyStats = await VpnStatisticsService.getWeeklyStats();

    // Если VPN подключен, добавляем текущую сессию к дневной статистике
    if (_isVpnConnected && sessionDuration.inSeconds > 0) {
      final currentSessionData =
          VpnStatisticsService.estimateDataTransferred(sessionDuration);
      dailyStats['dataTransferred'] =
          (dailyStats['dataTransferred'] as int) + currentSessionData;
      dailyStats['duration'] =
          (dailyStats['duration'] as int) + sessionDuration.inSeconds;
    }

    if (mounted) {
      setState(() {
        _sessionDuration = sessionDuration;
        _dailyStats = dailyStats;
        _weeklyStats = weeklyStats;
      });
    }
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Обновляем время сессии в реальном времени только если VPN подключен
      if (_isVpnConnected) {
        final sessionDuration = await VpnStatisticsService.getSessionDuration();
        if (mounted) {
          setState(() {
            _sessionDuration = sessionDuration;
          });
        }
      } else {
        // Если VPN отключен, сбрасываем время сессии
        if (mounted && _sessionDuration != Duration.zero) {
          setState(() {
            _sessionDuration = Duration.zero;
          });
        }
      }

      // Обновляем остальную статистику реже
      if (timer.tick % 5 == 0) {
        _loadStatistics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Text(
          'Статистика',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        leading: AnimatedBackButton(
          iconColor: colorScheme.onSurface,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.background,
              colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: BlocListener<VpnBloc, VpnState>(
          listener: (context, state) {
            // Обновляем флаг подключения и статистику при изменении состояния VPN
            final wasConnected = _isVpnConnected;
            final isNowConnected =
                state.connectionState == FlutterVpnState.connected;

            if (isNowConnected != wasConnected) {
              setState(() {
                _isVpnConnected = isNowConnected;
              });

              if (isNowConnected && !wasConnected) {
                // VPN только что подключился - загружаем статистику и начинаем обновление
                _loadStatistics();
                // Сразу обновляем время сессии
                VpnStatisticsService.getSessionDuration().then((duration) {
                  if (mounted) {
                    setState(() {
                      _sessionDuration = duration;
                    });
                  }
                });
              } else if (!isNowConnected && wasConnected) {
                // VPN только что отключился - обновляем статистику
                _loadStatistics();
                setState(() {
                  _sessionDuration = Duration.zero;
                });
              }
            }
          },
          child: BlocBuilder<VpnBloc, VpnState>(
            builder: (context, vpnState) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Статус подключения
                      _buildConnectionStatusCard(
                        context,
                        vpnState.connectionState,
                        colorScheme,
                        theme,
                      ),
                      const SizedBox(height: 20),

                      // Статистика за сессию
                      if (vpnState.connectionState == FlutterVpnState.connected)
                        _buildSessionStatsCard(
                          context,
                          vpnState,
                          colorScheme,
                          theme,
                        ),

                      if (vpnState.connectionState == FlutterVpnState.connected)
                        const SizedBox(height: 20),

                      // Статистика за сегодня
                      _buildDailyStatsCard(
                        context,
                        colorScheme,
                        theme,
                      ),
                      const SizedBox(height: 20),

                      // Статистика за неделю
                      _buildWeeklyStatsCard(
                        context,
                        colorScheme,
                        theme,
                      ),
                      const SizedBox(height: 20),

                      // Информация о сервере
                      if (vpnState.connectionState == FlutterVpnState.connected)
                        Builder(
                          builder: (context) {
                            try {
                              return BlocBuilder<ScreenStateBloc, ScreenStateState>(
                                builder: (context, screenState) {
                                  return _buildServerInfoCard(
                                    context,
                                    vpnState,
                                    colorScheme,
                                    theme,
                                    screenState,
                                  );
                                },
                              );
                            } catch (e) {
                              // Если ScreenStateBloc недоступен, показываем карточку без информации о сервере
                              return _buildServerInfoCard(
                                context,
                                vpnState,
                                colorScheme,
                                theme,
                                ScreenStateInitial(),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard(
    BuildContext context,
    FlutterVpnState state,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (state) {
      case FlutterVpnState.connected:
        statusText = 'Подключено';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case FlutterVpnState.connecting:
        statusText = 'Подключение...';
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        break;
      case FlutterVpnState.disconnecting:
        statusText = 'Отключение...';
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        break;
      default:
        statusText = 'Отключено';
        statusColor = colorScheme.onSurfaceVariant;
        statusIcon = Icons.power_settings_new_rounded;
    }

    return FadeInWidget(
      delay: const Duration(milliseconds: 50),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(0.1),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статус VPN',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStatsCard(
    BuildContext context,
    VpnState vpnState,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    // Время обновляется через setState каждую секунду
    final sessionDuration = _formatDuration(_sessionDuration);
    // Для текущей сессии используем симуляцию на основе времени
    final currentSessionData = _isVpnConnected
        ? VpnStatisticsService.estimateDataTransferred(_sessionDuration)
        : 0;
    final dataTransferred =
        VpnStatisticsService.formatBytes(currentSessionData);
    final speed = '—'; // TODO: Получить реальную скорость из VPN

    return FadeInWidget(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Текущая сессия',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Время',
                    sessionDuration,
                    Icons.access_time_rounded,
                    colorScheme,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Данные',
                    dataTransferred,
                    Icons.data_usage_rounded,
                    colorScheme,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              context,
              'Скорость',
              speed,
              Icons.speed_rounded,
              colorScheme,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStatsCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final duration = _dailyStats['duration'] as int? ?? 0;
    final dataTransferred = _dailyStats['dataTransferred'] as int? ?? 0;
    final connectionsCount = _dailyStats['connectionsCount'] as int? ?? 0;
    return FadeInWidget(
      delay: const Duration(milliseconds: 150),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Сегодня',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatRow(
              context,
              'Время подключения',
              VpnStatisticsService.formatDuration(duration),
              colorScheme,
              theme,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              'Передано данных',
              VpnStatisticsService.formatBytes(dataTransferred),
              colorScheme,
              theme,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              'Подключений',
              '$connectionsCount',
              colorScheme,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatsCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final duration = _weeklyStats['duration'] as int? ?? 0;
    final dataTransferred = _weeklyStats['dataTransferred'] as int? ?? 0;
    final connectionsCount = _weeklyStats['connectionsCount'] as int? ?? 0;
    return FadeInWidget(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_view_week_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'За неделю',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatRow(
              context,
              'Общее время',
              VpnStatisticsService.formatDuration(duration),
              colorScheme,
              theme,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              'Передано данных',
              VpnStatisticsService.formatBytes(dataTransferred),
              colorScheme,
              theme,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              'Подключений',
              '$connectionsCount',
              colorScheme,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerInfoCard(
    BuildContext context,
    VpnState vpnState,
    ColorScheme colorScheme,
    ThemeData theme,
    ScreenStateState screenStateState,
  ) {
    final vpnBloc = context.read<VpnBloc>();
    final currentServer = vpnBloc.currentServer;

    String serverName = 'Сервер не выбран';
    String serverIP = '—';
    String serverLocation = '—';

    if (currentServer != null) {
      serverIP = currentServer.host;

      // Пытаемся найти информацию о сервере из ScreenStateBloc
      if (screenStateState is ScreenStateLoaded) {
        final servers = screenStateState.rootModel?.servers ?? [];
        if (servers.isNotEmpty) {
          try {
            final server = servers.firstWhere(
              (s) => s.url == currentServer.host || s.ip == currentServer.host,
            );
            serverName = server.name ?? 'Неизвестный сервер';
            serverLocation = server.country ?? 'Неизвестно';
          } catch (e) {
            // Если сервер не найден, используем первый доступный или IP
            if (servers.isNotEmpty) {
              final firstServer = servers.first;
              serverName = firstServer.name ?? currentServer.host;
              serverLocation = firstServer.country ?? 'Неизвестно';
            } else {
              serverName = currentServer.host;
            }
          }
        } else {
          // Если список серверов пуст, используем только IP
          serverName = currentServer.host;
        }
      } else {
        // Если состояние не загружено, используем только IP
        serverName = currentServer.host;
      }
    }

    return FadeInWidget(
      delay: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dns_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Информация о сервере',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              context,
              'Название',
              serverName,
              colorScheme,
              theme,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'IP-адрес',
              serverIP,
              colorScheme,
              theme,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Локация',
              serverLocation,
              colorScheme,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours ч $minutes мин';
    }
    return '$minutes мин';
  }
}
