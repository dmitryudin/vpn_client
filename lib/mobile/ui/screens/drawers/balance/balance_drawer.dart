import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/bloc/screen_state_bloc.dart';
import '../../../widgets/animated_card.dart';
import '../../../widgets/animated_button.dart';

class BalanceIndicator extends StatefulWidget {
  const BalanceIndicator({Key? key}) : super(key: key);

  @override
  _BalanceIndicatorState createState() => _BalanceIndicatorState();
}

class _BalanceIndicatorState extends State<BalanceIndicator>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  String? _description;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 100),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  // Заголовок с балансом
                  Container(
                    padding: const EdgeInsets.only(
                      top: 60,
                      bottom: 32,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Баланс',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value * value,
                              child: child,
                            );
                          },
                          child: _buildBalanceCircle(balance, colorScheme, theme),
                        ),
                      ],
                    ),
                  ),
                  // Информация о тарифе
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                                if (_isExpanded && state is ScreenStateLoaded) {
                                  try {
                                _description = state.rootModel?.tariffs
                                    .firstWhere((t) => t.id == current_tarif_id)
                                    .descryption;
                                  } catch (e) {
                                    _description = null;
                                  }
                              }
                            });
                          },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.onPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Ваш тариф: $name',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedRotation(
                                    turns: _isExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                    if (_isExpanded && _description != null)
                      Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.onPrimary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                        child: Text(
                          _description!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                              ),
                        ),
                      ),
                  ],
                ),
                  ),
                  const SizedBox(height: 24),
                  // Меню
                Expanded(
                    child: _buildMenuSection(colorScheme, theme, state),
                ),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCircle(
    int balance,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final progress = (balance / 30).clamp(0.0, 1.0);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
                color: colorScheme.onPrimary.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
                width: 200,
                height: 200,
            child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 12,
                  backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              ),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onPrimary.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: balance),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedBalance, child) {
                        return Text(
                          '$animatedBalance',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
              Text(
                'дней',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(
    ColorScheme colorScheme,
    ThemeData theme,
    ScreenStateState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.only(top: 8),
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
                                icon: Icons.shopping_cart_rounded,
                                title: 'Сменить тариф',
                                onTap: () => context.push('/tariff'),
                                colorScheme: colorScheme,
                                theme: theme,
                                index: 0,
                              )
                            : Container()
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: AnimatedButton(
                              onPressed: () => context.push('/auth'),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.login_rounded),
                                  SizedBox(width: 8),
                                  Text('Авторизация'),
                                ],
                              ),
                            ),
                          );
                  }
                case (ScreenStateError):
                  return Container();
              }
              return Container();
            },
          ),

          _buildMenuItem(
            icon: Icons.star_rounded,
            title: 'Оценить и получить 5 дней',
            onTap: () {
              if (GetIt.I<AuthService>().user.authStatus ==
                  AuthStatus.authorized) {
                // TODO: Реализовать оценку приложения
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Внимание'),
                    content: const Text(
                              'Получение бонусов доступно только авторизованным пользователям'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Понятно'),
                      ),
                    ],
                  ),
                );
              }
            },
            colorScheme: colorScheme,
            theme: theme,
            index: 1,
          ),
          _buildMenuItem(
            icon: Icons.person_add_rounded,
            title: 'Пригласить друга 5 дней',
            onTap: () {
              if (GetIt.I<AuthService>().user.authStatus ==
                  AuthStatus.authorized) {
                Navigator.pop(context);
                Future.delayed(
                  const Duration(milliseconds: 200),
                  () => context.push('/invite'),
                );
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Внимание'),
                    content: const Text(
                              'Получение бонусов доступно только авторизованным пользователям'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Понятно'),
                      ),
                    ],
                  ),
                );
              }
            },
            colorScheme: colorScheme,
            theme: theme,
            index: 2,
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
    required ThemeData theme,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset((1 - value) * 20, 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: AnimatedCard(
        onTap: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 200), onTap);
        },
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(16),
        backgroundColor: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
