import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/state.dart';
import 'package:vpn/mobile/utils/bloc/screen_state_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_event.dart';
import 'package:vpn_engine/from_server/api_server/models/server_http_model.dart';
import '../../utils/vpn_bloc/vpn_state.dart';
import 'animated_card.dart';
import 'fade_in_widget.dart';
import 'skeleton_loader.dart';
import 'empty_state.dart';

/// Улучшенный список серверов с современным UX
class EnhancedServerList extends StatefulWidget {
  const EnhancedServerList({Key? key}) : super(key: key);

  @override
  State<EnhancedServerList> createState() => _EnhancedServerListState();
}

class _EnhancedServerListState extends State<EnhancedServerList>
    with SingleTickerProviderStateMixin {
  String? selectedServer;
  ServerHttpModel? currentServer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<ScreenStateBloc>().add(LoadServerList());
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: BlocBuilder<ScreenStateBloc, ScreenStateState>(
        builder: (context, state) {
          return BlocBuilder<VpnBloc, VpnState>(
            builder: (context, vpnState) {
              bool isEnabled =
                  vpnState.connectionState != FlutterVpnState.connected;

              ServerHttpModel? displayServer = currentServer;
              if (state is ScreenStateLoaded &&
                  state.rootModel?.servers?.isNotEmpty == true) {
                if (displayServer == null) {
                  displayServer = state.rootModel?.servers?.first;
                  if (displayServer != null) {
                    selectedServer ??= displayServer.id.toString();
                    if (BlocProvider.of<VpnBloc>(context).currentServer ==
                        null) {
                      BlocProvider.of<VpnBloc>(context).currentServer =
                          CurrentServer(
                        host: displayServer.url!,
                        userName: displayServer.username!,
                        password: displayServer.password!,
                      );
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          currentServer = displayServer;
                        });
                      }
                    });
                  }
                } else {
                  selectedServer ??= displayServer.id.toString();
                }
              }

              switch (state.runtimeType) {
                case ScreenStateInitial:
                  return _buildLoadingState(colorScheme);
                  
                case ScreenStateError:
                  return _buildErrorState(context, colorScheme, textTheme);
                  
                case ScreenStateLoaded:
                  final serverToShow = displayServer ??
                      (state.rootModel?.servers?.isNotEmpty == true
                          ? state.rootModel!.servers!.first
                          : null);

                  if (serverToShow == null) {
                    return _buildEmptyState(colorScheme, textTheme);
                  }

                  return _buildServerCard(
                    context,
                    serverToShow,
                    isEnabled,
                    state.rootModel!.servers!,
                    colorScheme,
                    textTheme,
                  );

                default:
                  return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return const ServerCardSkeleton();
  }

  Widget _buildErrorState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Ошибка загрузки серверов',
      message: 'Произошла ошибка при загрузке списка серверов. Проверьте подключение к интернету.',
      actionLabel: 'Повторить',
      onAction: () {
        context.read<ScreenStateBloc>().add(LoadServerList());
      },
      iconColor: colorScheme.error,
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Серверы не найдены',
      message: 'Не удалось загрузить список серверов. Проверьте подключение к интернету и попробуйте снова.',
      actionLabel: 'Обновить',
      onAction: () {
        context.read<ScreenStateBloc>().add(LoadServerList());
      },
    );
  }

  Widget _buildServerCard(
    BuildContext context,
    ServerHttpModel server,
    bool isEnabled,
    List<ServerHttpModel> allServers,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: FadeInWidget(
        delay: const Duration(milliseconds: 100),
        child: AnimatedCard(
          onTap: isEnabled
              ? () {
                  _showServerSelectionSheet(
                    context,
                    allServers,
                    colorScheme,
                    textTheme,
                  );
                }
              : null,
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(20),
          backgroundColor: colorScheme.surface,
          child: Row(
            children: [
              // Флаг страны
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    getCountryFlag(server.country ?? ''),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Информация о сервере
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      server.name ?? 'No name',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          server.ip ?? '',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Индикатор загрузки
              _buildLoadIndicator(
                server.load_coef ?? 0,
                colorScheme,
              ),
              
              if (isEnabled) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadIndicator(double loadCoef, ColorScheme colorScheme) {
    Color color;
    IconData icon;
    
    // loadCoef: чем меньше значение, тем ниже загрузка сервера и выше скорость
    // Низкая загрузка (loadCoef < 0.4) = высокая скорость = полная иконка WiFi (4 полоски)
    // Средняя загрузка (0.4 <= loadCoef < 0.7) = средняя скорость = 2 полоски
    // Высокая загрузка (loadCoef >= 0.7) = низкая скорость = 1 полоска
    
    // Логика: меньше loadCoef = лучше = больше полосок WiFi
    if (loadCoef < 0.4) {
      // Низкая загрузка - высокая скорость - лучший сигнал
      color = Colors.green;
      icon = Icons.wifi; // Полная иконка WiFi - максимальный сигнал
    } else if (loadCoef < 0.7) {
      // Средняя загрузка - средняя скорость - средний сигнал
      color = Colors.orange;
      icon = Icons.wifi_2_bar; // 2 полоски - средний сигнал
    } else {
      // Высокая загрузка - низкая скорость - слабый сигнал
      color = colorScheme.error;
      icon = Icons.wifi_1_bar; // 1 полоска - минимальный сигнал
    }
    
    return Icon(icon, color: color, size: 24);
  }

  void _showServerSelectionSheet(
    BuildContext context,
    List<ServerHttpModel> servers,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Заголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Выберите сервер',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded),
                    color: colorScheme.onSurfaceVariant,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Список серверов
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  final server = servers[index];
                  final isSelected = selectedServer == server.id.toString();
                  
                  return _buildServerListItem(
                    context,
                    server,
                    isSelected,
                    colorScheme,
                    textTheme,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerListItem(
    BuildContext context,
    ServerHttpModel server,
    bool isSelected,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          BlocProvider.of<VpnBloc>(context).add(
            ChangeServerEvent(
              host: server.url ?? '',
              userName: server.username ?? '',
              password: server.password ?? '',
            ),
          );
          setState(() {
            selectedServer = server.id.toString();
            currentServer = server;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    getCountryFlag(server.country ?? ''),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      server.name ?? 'No name',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      server.ip ?? '',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLoadIndicator(server.load_coef ?? 0, colorScheme),
              if (isSelected) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String getCountryFlag(String countryCode) {
  final flag = countryCode.toUpperCase().replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
      );
  return flag;
}
