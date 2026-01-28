import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/main.dart';
import 'package:vpn/mobile/ui/screens/drawers/balance/balance_drawer.dart';
import 'package:vpn/mobile/ui/screens/drawers/profile/profile_drawer.dart';
import 'package:vpn/mobile/ui/widgets/enhanced_server_list.dart';
import 'package:vpn/mobile/ui/widgets/enhanced_vpn_button.dart';
import 'package:vpn/mobile/ui/widgets/animated_icon_button.dart';
import 'package:vpn/mobile/ui/widgets/fade_in_widget.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_state.dart';
import 'package:vpn/mac_os/utils/bloc/screen_state_bloc.dart';
import 'package:flutter_vpn/state.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String email = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUpdates(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (email.isEmpty) {
              email = snapshot.data!.getString('user_email') ?? '';
            }

            return Scaffold(
              key: _scaffoldKey,
              appBar: _buildEnhancedAppBar(context, colorScheme, theme),
              drawer: ProfileDrawer(),
              endDrawer: BalanceIndicator(),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.background,
                      colorScheme.surfaceVariant,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Обновляем список серверов
                      context.read<ScreenStateBloc>().add(LoadServerList());
                      // Ждем немного для плавности
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    color: colorScheme.primary,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeInWidget(
                                delay: const Duration(milliseconds: 100),
                                child: const EnhancedVpnButton(),
                              ),
                              const SizedBox(height: 48),
                              FadeInWidget(
                                delay: const Duration(milliseconds: 200),
                                child: const EnhancedServerList(),
                              ),
                            ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: theme.primaryColor,
            ),
          );
        });
  }

  PreferredSizeWidget _buildEnhancedAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      leading: AnimatedIconButton(
        icon: Iconsax.arrow_left_2,
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        tooltip: 'Меню',
      ),
      title: BlocBuilder<VpnBloc, VpnState>(
        builder: (context, vpnState) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Индикатор статуса VPN
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(vpnState.connectionState, colorScheme),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(vpnState.connectionState, colorScheme)
                          .withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(vpnState.connectionState),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // Быстрый доступ к статистике
        BlocBuilder<VpnBloc, VpnState>(
          builder: (context, vpnState) {
            if (vpnState.connectionState == FlutterVpnState.connected) {
              return AnimatedIconButton(
                icon: Icons.bar_chart_rounded,
                tooltip: 'Статистика',
                onPressed: () => context.push('/statistics'),
                iconColor: colorScheme.primary,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // Быстрый доступ к автоматизации
        AnimatedIconButton(
          icon: Iconsax.flash_1,
          tooltip: 'Автоматизация',
          onPressed: () => context.push('/automation'),
        ),
        // Баланс
        AnimatedIconButton(
          icon: Iconsax.arrow_right_3,
          tooltip: 'Баланс',
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  Color _getStatusColor(FlutterVpnState state, ColorScheme colorScheme) {
    switch (state) {
      case FlutterVpnState.connected:
        return Colors.green;
      case FlutterVpnState.connecting:
      case FlutterVpnState.disconnecting:
        return Colors.orange;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(FlutterVpnState state) {
    switch (state) {
      case FlutterVpnState.connected:
        return 'Подключено';
      case FlutterVpnState.connecting:
        return 'Подключение...';
      case FlutterVpnState.disconnecting:
        return 'Отключение...';
      default:
        return 'Отключено';
    }
  }
}
