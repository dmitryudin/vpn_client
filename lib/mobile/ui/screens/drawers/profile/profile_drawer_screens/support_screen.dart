import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vpn/mobile/ui/widgets/animated_back_button.dart';
import 'package:vpn/mobile/ui/widgets/animated_card.dart';
import 'package:vpn/mobile/ui/widgets/fade_in_widget.dart';
import 'package:vpn/mobile/ui/widgets/enhanced_toast.dart';

class SupportScreen extends StatefulWidget {
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Поддержка',
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
                child: _buildContactCard(
                  context,
                  Icons.email_rounded,
                  'Email',
                  'support@cryptovpn.com',
                  'Написать на email',
                  () async {
                    final uri = Uri.parse('mailto:support@cryptovpn.com');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      EnhancedToast.show(
                        context,
                        message: 'Не удалось открыть почтовое приложение',
                        type: ToastType.error,
                      );
                    }
                  },
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(height: 16),
              FadeInWidget(
                delay: const Duration(milliseconds: 150),
                child: _buildContactCard(
                  context,
                  Icons.phone_rounded,
                  'Телефон',
                  '+7 (999) 123-45-67',
                  'Позвонить',
                  () async {
                    final uri = Uri.parse('tel:+79991234567');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      EnhancedToast.show(
                        context,
                        message: 'Не удалось открыть телефонное приложение',
                        type: ToastType.error,
                      );
                    }
                  },
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(height: 16),
              FadeInWidget(
                delay: const Duration(milliseconds: 200),
                child: _buildContactCard(
                  context,
                  Icons.chat_bubble_rounded,
                  'Онлайн чат',
                  'Доступен 24/7',
                  'Открыть чат',
                  () {
                    EnhancedToast.show(
                      context,
                      message: 'Чат временно недоступен',
                      type: ToastType.info,
                    );
                  },
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(height: 20),
              FadeInWidget(
                delay: const Duration(milliseconds: 250),
                child: _buildInfoCard(
                  context,
                  Icons.access_time_rounded,
                  'Время работы',
                  'Наша служба поддержки работает круглосуточно, 7 дней в неделю. Мы всегда готовы помочь вам!',
                  colorScheme,
                  theme,
                ),
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
            width: 80,
            height: 80,
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
              Icons.support_agent_rounded,
              size: 40,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Свяжитесь с нами',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Мы всегда готовы помочь вам с любыми вопросами',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String buttonText,
    VoidCallback onTap,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return AnimatedCard(
      padding: EdgeInsets.zero,
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
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
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      buttonText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
              color: colorScheme.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colorScheme.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
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
}
