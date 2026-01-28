import 'package:auth_feature/auth_feature.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../localization/app_localization.dart';
import '../../../widgets/animated_card.dart';

class ProfileDrawer extends StatefulWidget {
  final String languageCode;
  const ProfileDrawer({this.languageCode = 'ru', Key? key}) : super(key: key);

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
    final textTheme = theme.textTheme;
    String email = GetIt.I<AuthService>().user.email;

    bool isAuthorized = email.isNotEmpty;

    return Drawer(
      child: SafeArea(
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
              // Заголовок с аватаркой
              Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 32,
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: isAuthorized
                            ? Center(
                                child: Text(
                                  email[0].toUpperCase(),
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 40,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Icon(
                                Iconsax.profile_circle,
                                size: 60,
                                color: colorScheme.primary,
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isAuthorized) ...[
                      Text(
                        'Ваша почта',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          email,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ] else
                      ElevatedButton.icon(
                        onPressed: () => context.push('/auth'),
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text('Зарегистрироваться'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          backgroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Меню
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 16,
                    ),
                    children: [
                      _buildMenuItem(
                        icon: Icons.bar_chart_rounded,
                        title: 'Статистика',
                        onTap: () => context.push('/statistics'),
                        colorScheme: colorScheme,
                        theme: theme,
                        index: 0,
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_rounded,
                        title: AppLocalization.translate(
                            'settings', widget.languageCode),
                        onTap: () async {
                          await context.push('/settings');
                          setState(() {
                            email = GetIt.I<AuthService>().user.email;
                            if (email.isEmpty) {
                              isAuthorized = false;
                            }
                          });
                        },
                        colorScheme: colorScheme,
                        theme: theme,
                        index: 1,
                      ),
                      _buildMenuItem(
                        icon: Iconsax.flash_1,
                        title: 'Автоматизации',
                        onTap: () => context.push('/automation'),
                        colorScheme: colorScheme,
                        theme: theme,
                        index: 2,
                      ),
                      _buildMenuItem(
                        icon: Icons.star_rounded,
                        title: 'Оценить приложение',
                        onTap: () {},
                        colorScheme: colorScheme,
                        theme: theme,
                        index: 3,
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'О нас',
                        onTap: () => context.push('/about'),
                        colorScheme: colorScheme,
                        theme: theme,
                        index: 4,
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'FAQ',
                        onTap: () => context.push('/faq'),
                        colorScheme: colorScheme,
                        theme: theme,
                        index: 5,
                      ),
                      _buildMenuItem(
                        icon: Icons.support_agent_rounded,
                        title: 'Поддержка',
                        onTap: () => context.push('/support'),
                        colorScheme: colorScheme,
                        theme: theme,
                        index: 6,
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
        enableHapticFeedback: true,
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
