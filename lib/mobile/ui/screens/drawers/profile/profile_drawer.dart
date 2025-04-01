import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../localization/app_localization.dart';

class ProfileDrawer extends StatelessWidget {
  final String email;
  final String languageCode;

  const ProfileDrawer({required this.email, this.languageCode = 'ru'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bool isAuthorized = email.isNotEmpty;

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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.onPrimary,
                    child: isAuthorized
                        ? Text(
                            email[0].toUpperCase(),
                            style: textTheme.bodyLarge?.copyWith(
                              fontSize: 32,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Icon(Iconsax.profile_circle,
                            size: 50, color: theme.scaffoldBackgroundColor),
                  ),
                  SizedBox(height: 20),
                  if (isAuthorized) ...[
                    Text(
                      'Ваша почта:',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.focusColor.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      email,
                      style: textTheme.bodyLarge?.copyWith(
                        color: theme.focusColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else
                    ElevatedButton(
                      onPressed: () => context.push('/auth'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: colorScheme.onPrimary,
                        backgroundColor: colorScheme.primary,
                      ),
                      child: Text('Зарегистрироваться'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(
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
                    _buildMenuItem(
                      icon: Icons.settings,
                      title:
                          AppLocalization.translate('settings', languageCode),
                      onTap: () => context.push('/settings'),
                      colorScheme: colorScheme,
                    ),
                    _buildMenuItem(
                      icon: Icons.star,
                      title: 'Оценить приложение',
                      onTap: () {},
                      colorScheme: colorScheme,
                    ),
                    _buildMenuItem(
                      icon: Icons.info,
                      title: 'О нас',
                      onTap: () => context.push('/about'),
                      colorScheme: colorScheme,
                    ),
                    _buildMenuItem(
                      icon: Icons.question_answer,
                      title: 'FAQ',
                      onTap: () => context.push('/faq'),
                      colorScheme: colorScheme,
                    ),
                    _buildMenuItem(
                      icon: Icons.support,
                      title: 'Поддержка',
                      onTap: () => context.push('/support'),
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          color: colorScheme.onPrimary.withOpacity(0.1),
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
