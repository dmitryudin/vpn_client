import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/localization/app_localization.dart';
import 'package:vpn/mobile/ui/widgets/enhanced_dropdown.dart';
import 'package:vpn/mobile/ui/widgets/animated_card.dart';
import 'package:vpn/mobile/ui/widgets/animated_back_button.dart';

import 'package:vpn/mobile/utils/bloc/screen_state_bloc.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool adBlockEnabled = false;
  bool killSwitchEnabled = false;
  String selectedThemeMode = 'Системная';
  String selectedLanguage = 'Русский';
  final List<String> languages = ['Русский', 'English'];
  final List<String> themeModes = ['Системная', 'Светлая', 'Тёмная'];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    _loadThemeMode();
  }

  void _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppLocalization.LANGUAGE_CODE) ?? 'ru';
    setState(() {
      selectedLanguage = languageCode == 'en' ? 'English' : 'Русский';
    });
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString('themeMode') ?? 'system';
    setState(() {
      if (savedThemeMode == 'light') {
        selectedThemeMode = 'Светлая';
      } else if (savedThemeMode == 'dark') {
        selectedThemeMode = 'Тёмная';
      } else {
        selectedThemeMode = 'Системная';
      }
    });
  }

  void _changeLanguage(String? newLanguage) async {
    if (newLanguage != null) {
      final prefs = await SharedPreferences.getInstance();
      String languageCode = newLanguage == 'English' ? 'en' : 'ru';
      // Сохраняем язык
      await prefs.setString(AppLocalization.LANGUAGE_CODE, languageCode);
      setState(() {
        selectedLanguage = newLanguage;
      });
      // Перезапускаем приложение
      if (mounted) {
        Phoenix.rebirth(context);
      }
    }
  }

  void _changeThemeMode(String? newThemeMode) async {
    if (newThemeMode != null) {
    final prefs = await SharedPreferences.getInstance();
      String themeModeValue;
      if (newThemeMode == 'Светлая') {
        themeModeValue = 'light';
      } else if (newThemeMode == 'Тёмная') {
        themeModeValue = 'dark';
      } else {
        themeModeValue = 'system';
      }
      
      await prefs.setString('themeMode', themeModeValue);
    setState(() {
        selectedThemeMode = newThemeMode;
    });
      // Перезапускаем приложение для применения темы
      if (mounted) {
    Phoenix.rebirth(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalization.translate('settings', 'ru'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        leading: AnimatedBackButton(
          iconColor: colorScheme.onPrimary,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.background,
              colorScheme.surfaceVariant,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            AnimatedCard(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: EnhancedDropdown<String>(
                value: selectedLanguage,
                items: languages,
                itemBuilder: (item) => item,
                onChanged: _changeLanguage,
                label: AppLocalization.translate('language', 'ru'),
                icon: Icons.language_rounded,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedCard(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: EnhancedDropdown<String>(
                value: selectedThemeMode,
                items: themeModes,
                itemBuilder: (item) => item,
                onChanged: _changeThemeMode,
                label: 'Тема приложения',
                icon: Icons.palette_rounded,
              ),
            ),
            const SizedBox(height: 24),
            _buildSwitchCard(
              'AdBlock',
              'Блокировка рекламы и трекеров',
              adBlockEnabled,
              (value) => setState(() => adBlockEnabled = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchCard(
              'Kill Switch',
              'Защита от утечки данных при обрыве VPN',
              killSwitchEnabled,
              (value) => setState(() => killSwitchEnabled = value),
            ),
            const SizedBox(height: 20),
            if (GetIt.I<AuthService>().user.authStatus == AuthStatus.authorized) ...[
              _buildActionButton(
                context,
                'Выйти из профиля',
                Icons.logout_rounded,
                colorScheme.primary,
                () async {
                  final confirm = await _showModernDialog(
                    context,
                    title: 'Выход из профиля',
                    message: 'Вы уверены, что хотите выйти?',
                    confirmText: 'Выйти',
                    confirmColor: colorScheme.primary,
                  );
                  if (confirm == true && mounted) {
                    await BlocProvider.of<ScreenStateBloc>(context).logOut();
                    if (mounted) context.pop();
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                context,
                'Удалить аккаунт',
                Icons.delete_outline_rounded,
                colorScheme.error,
                () async {
                  final confirm = await _showModernDialog(
                    context,
                    title: 'Удаление аккаунта',
                    message: 'Вы уверены, что хотите удалить аккаунт? Это действие нельзя отменить.',
                    confirmText: 'Удалить',
                    confirmColor: colorScheme.error,
                    isDestructive: true,
                  );
                  if (confirm == true && mounted) {
                    await BlocProvider.of<ScreenStateBloc>(context).logOut();
                    if (mounted) context.pop();
                  }
                                    },
                                  ),
                                ],
          ],
        ),
      ),
    );
  }


  Widget _buildSwitchCard(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedCard(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
      color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedCard(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
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
          ),
        ),
      ),
    );
  }

  Future<bool?> _showModernDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
      color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDestructive ? colorScheme.error : confirmColor,
                      (isDestructive ? colorScheme.error : confirmColor)
                          .withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDestructive
                            ? Icons.warning_rounded
                            : Icons.info_outline_rounded,
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Сообщение
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Кнопки
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          confirmText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
