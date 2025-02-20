import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/bloc/screen_state_bloc.dart';

class BalanceIndicator extends StatefulWidget {
  const BalanceIndicator({Key? key}) : super(key: key);

  @override
  _BalanceIndicatorState createState() => _BalanceIndicatorState();
}

class _BalanceIndicatorState extends State<BalanceIndicator> {
  bool _isExpanded = false;
  String? _description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ScreenStateBloc, ScreenStateState>(
      builder: (context, state) {
        int balance;
        int current_tarif_id;
        String name = '';

        switch (state.runtimeType) {
          case ScreenStateLoaded:
            balance = ((state.rootModel?.user_info?.balance) ?? 0).toInt();
            break;
          default:
            balance = 0;
        }

        switch (state.runtimeType) {
          case ScreenStateLoaded:
            current_tarif_id =
                ((state.rootModel?.user_info?.current_tarif_id) ?? 0).toInt();
            break;
          default:
            current_tarif_id = 0;
        }
        switch (state.runtimeType) {
          case ScreenStateLoaded:
            name = ((state.rootModel?.tariffs
                        .firstWhere((e) => e.id == current_tarif_id)
                        .name) ??
                    0)
                .toString();
            break;
          default:
        }
        switch (state.runtimeType) {
          case ScreenStateLoaded:
            name = ((state.rootModel?.tariffs
                        .firstWhere((e) => e.id == current_tarif_id)
                        .name) ??
                    0)
                .toString();
            break;
          default:
        }

        return Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor,
                  theme.cardColor,
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        'Баланс',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildBalanceCircle(balance, colorScheme),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ваш тариф: $name',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                              if (_isExpanded) {
                                _description = state.rootModel?.tariffs
                                    .firstWhere((t) => t.id == current_tarif_id)
                                    .descryption;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isExpanded && _description != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Text(
                          _description!,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: _buildMenuSection(colorScheme),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCircle(int balance, ColorScheme colorScheme) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: balance / 30,
              strokeWidth: 15,
              backgroundColor: colorScheme.onPrimary.withOpacity(0.24),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$balance',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'дней',
                style: TextStyle(
                  color: colorScheme.onPrimary.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        children: [
          // (GetIt.I<AuthService>().user.authStatus == AuthStatus.authorized)
          BlocBuilder<ScreenStateBloc, ScreenStateState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                case (ScreenStateInitial):
                  return Container();
                case (ScreenStateLoaded):
                  {
                    return (GetIt.I<AuthService>().user.authStatus ==
                            AuthStatus.authorized)
                        ? (state.rootModel!.user_info!.current_tarif_id == 1)
                            ? _buildMenuItem(
                                icon: Icons.shopping_cart,
                                title: 'Сменить тариф',
                                onTap: () => context.push('/tariff'),
                                colorScheme: colorScheme,
                              )
                            : Container()
                        : ElevatedButton(
                            onPressed: () => context.push('/auth'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: colorScheme.onPrimary,
                              backgroundColor: colorScheme.primary,
                            ),
                            child: Text('Авторизация'),
                          );
                  }
                case (ScreenStateError):
                  return Container();
              }
              return Container();
            },
          ),

          _buildMenuItem(
            icon: Icons.star,
            title: 'Оценить и получить 5 дней',
            onTap: () {
              if (GetIt.I<AuthService>().user.authStatus ==
                  AuthStatus.authorized) {
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext) => AlertDialog(
                          title: Text('Внимание'),
                          content: Text(
                              'Получение бонусов доступно только авторизованным пользователям'),
                        ));
              }
            },
            colorScheme: colorScheme,
          ),
          _buildMenuItem(
            icon: Icons.person_add,
            title: 'Пригласить друга 5 дней',
            onTap: () {
              if (GetIt.I<AuthService>().user.authStatus ==
                  AuthStatus.authorized) {
                context.push('/invite');
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext) => AlertDialog(
                          title: Text('Внимание'),
                          content: Text(
                              'Получение бонусов доступно только авторизованным пользователям'),
                        ));
              }
            },
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: colorScheme.onBackground,
        ),
      ),
      onTap: onTap,
    );
  }
}
