import 'package:flutter/material.dart';
import 'package:vpn/mobile/ui/widgets/animated_back_button.dart';
import 'package:vpn/mobile/ui/widgets/animated_card.dart';
import 'package:vpn/mobile/ui/widgets/fade_in_widget.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'О нас',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0,
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
              colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInWidget(
                delay: const Duration(milliseconds: 50),
                child: _buildHeaderCard(context, theme, colorScheme),
              ),
              const SizedBox(height: 20),
              FadeInWidget(
                delay: const Duration(milliseconds: 100),
                child: _buildInfoCard(
                  context,
                  Icons.security_rounded,
                  'Безопасность',
                  'Мы используем передовые технологии шифрования для защиты ваших данных. Ваша конфиденциальность - наш приоритет.',
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(height: 16),
              FadeInWidget(
                delay: const Duration(milliseconds: 150),
                child: _buildInfoCard(
                  context,
                  Icons.speed_rounded,
                  'Скорость',
                  'Наши серверы расположены по всему миру, обеспечивая высокую скорость соединения в любой точке планеты.',
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(height: 16),
              FadeInWidget(
                delay: const Duration(milliseconds: 200),
                child: _buildInfoCard(
                  context,
                  Icons.support_agent_rounded,
                  'Поддержка',
                  'Наша команда поддержки работает 24/7, чтобы помочь вам с любыми вопросами или проблемами.',
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(height: 20),
              FadeInWidget(
                delay: const Duration(milliseconds: 250),
                child: _buildVersionCard(context, theme, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AnimatedCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.vpn_key_rounded,
              size: 50,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'CryptoVPN',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Защита вашей конфиденциальности в цифровом мире',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return AnimatedCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AnimatedCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Версия приложения',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
