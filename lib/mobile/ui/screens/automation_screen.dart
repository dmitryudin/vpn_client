import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/mobile/ui/widgets/animated_back_button.dart';
import 'package:vpn/mobile/ui/widgets/animated_card.dart';
import 'package:vpn/mobile/ui/widgets/fade_in_widget.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'dart:io';

class AutomationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Text(
          'Автоматизация',
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
        child: SafeArea(
          child: _ShortcutsAutomationSection(),
        ),
      ),
    );
  }
}

class _ShortcutsAutomationSection extends StatefulWidget {
  @override
  State<_ShortcutsAutomationSection> createState() =>
      _ShortcutsAutomationSectionState();
}

class _ShortcutsAutomationSectionState
    extends State<_ShortcutsAutomationSection> {
  static const _prefsKeySelected = 'shortcuts_selected_services_v1';

  final Map<String, ServiceInfo> _services = {
    'YouTube': ServiceInfo(
      name: 'YouTube',
      icon: Icons.play_circle_filled,
      color: Colors.red,
      domains: [
        'youtube.com',
        'www.youtube.com',
        'm.youtube.com',
        'youtu.be',
        'googlevideo.com',
        'ytimg.com',
        'youtubei.googleapis.com',
        'youtube.googleapis.com',
        'ggpht.com',
        'googleusercontent.com',
      ],
    ),
    'Instagram': ServiceInfo(
      name: 'Instagram',
      icon: Icons.camera_alt,
      color: Color(0xFFE4405F),
      domains: [
        'instagram.com',
        'www.instagram.com',
        'm.instagram.com',
        'cdninstagram.com',
        'graph.instagram.com',
        'instagramstatic-a.akamaihd.net',
        'instagramstatic-b.akamaihd.net',
        'fbcdn.net',
        'fb.com',
        'facebook.com',
        'fbcdnphotos-a.akamaihd.net',
        'fbcdnphotos-b.akamaihd.net',
      ],
    ),
    'Facebook': ServiceInfo(
      name: 'Facebook',
      icon: Icons.facebook,
      color: Color(0xFF1877F2),
      domains: [
        'facebook.com',
        'www.facebook.com',
        'm.facebook.com',
        'web.facebook.com',
        'fb.com',
        'fbcdn.net',
        'facebook.net',
        'fbstatic-a.akamaihd.net',
        'fbstatic-b.akamaihd.net',
        'fbcdnphotos-a.akamaihd.net',
        'fbcdnphotos-b.akamaihd.net',
        'graph.facebook.com',
      ],
    ),
    'TikTok': ServiceInfo(
      name: 'TikTok',
      icon: Icons.music_note,
      color: Colors.black,
      domains: [
        'tiktok.com',
        'www.tiktok.com',
        'm.tiktok.com',
        'vm.tiktok.com',
        'tiktokcdn.com',
        'tiktokv.com',
        'musical.ly',
        'tiktokcdn-us.com',
        'ibyteimg.com',
        'bytedapm.com',
      ],
    ),
    'Telegram': ServiceInfo(
      name: 'Telegram',
      icon: Icons.send,
      color: Color(0xFF0088CC),
      domains: [
        'telegram.org',
        't.me',
        'web.telegram.org',
        'telegram.me',
        'core.telegram.org',
      ],
    ),
    'Twitter (X)': ServiceInfo(
      name: 'Twitter (X)',
      icon: Icons.alternate_email,
      color: Colors.black,
      domains: [
        'x.com',
        'twitter.com',
        'www.twitter.com',
        'mobile.twitter.com',
        't.co',
        'twimg.com',
        'abs.twimg.com',
        'pbs.twimg.com',
        'video.twimg.com',
        'api.twitter.com',
        'ads-twitter.com',
      ],
    ),
    'LinkedIn': ServiceInfo(
      name: 'LinkedIn',
      icon: Icons.business,
      color: Color(0xFF0077B5),
      domains: [
        'linkedin.com',
        'www.linkedin.com',
        'm.linkedin.com',
        'licdn.com',
        'media.licdn.com',
        'static.licdn.com',
      ],
    ),
    'Reddit': ServiceInfo(
      name: 'Reddit',
      icon: Icons.forum,
      color: Color(0xFFFF4500),
      domains: [
        'reddit.com',
        'www.reddit.com',
        'm.reddit.com',
        'old.reddit.com',
        'i.redd.it',
        'preview.redd.it',
        'redd.it',
        'redditstatic.com',
        'redditmedia.com',
      ],
    ),
    'Twitch': ServiceInfo(
      name: 'Twitch',
      icon: Icons.live_tv,
      color: Color(0xFF9146FF),
      domains: [
        'twitch.tv',
        'www.twitch.tv',
        'm.twitch.tv',
        'static-cdn.jtvnw.net',
        'vod-secure.twitch.tv',
        'usher.ttvnw.net',
        'api.twitch.tv',
        'clips-media-assets2.twitch.tv',
      ],
    ),
    'GitHub': ServiceInfo(
      name: 'GitHub',
      icon: Icons.code,
      color: Colors.black,
      domains: [
        'github.com',
        'www.github.com',
        'githubusercontent.com',
        'raw.githubusercontent.com',
        'avatars.githubusercontent.com',
        'github.io',
      ],
    ),
  };

  final Set<String> _selected = <String>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSelected();
  }

  Future<void> _loadSelected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKeySelected) ?? <String>[];
      setState(() {
        _selected
          ..clear()
          ..addAll(list.where(_services.containsKey));
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveSelected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKeySelected, _selected.toList());
    } catch (_) {}
  }

  Future<void> _triggerHaptic() async {
    if (await Haptics.canVibrate()) {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.light);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с описанием
          FadeInWidget(
            delay: const Duration(milliseconds: 50),
            child: _buildHeader(context, theme, colorScheme),
          ),
          const SizedBox(height: 24),

          // Список сервисов
          FadeInWidget(
            delay: const Duration(milliseconds: 100),
            child: _buildServicesGrid(context, theme, colorScheme),
          ),
          const SizedBox(height: 24),

          // Кнопка настройки
          if (_selected.isNotEmpty)
            FadeInWidget(
              delay: const Duration(milliseconds: 150),
              child: _buildSetupButton(context, theme, colorScheme),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AnimatedCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: colorScheme.onPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Автоматизация VPN',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Через приложение Команды',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Выберите приложения, для которых VPN будет включаться автоматически',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите сервисы',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _services.entries.map((entry) {
            final serviceName = entry.key;
            final serviceInfo = entry.value;
            final isSelected = _selected.contains(serviceName);
            
            return _buildServiceCard(
              context,
              theme,
              colorScheme,
              serviceName,
              serviceInfo,
              isSelected,
            );
          }).toList(),
        ),
        if (_selected.isNotEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Выбрано: ${_selected.length} из ${_services.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String serviceName,
    ServiceInfo serviceInfo,
    bool isSelected,
  ) {
    return AnimatedCard(
      onTap: () async {
        await _triggerHaptic();
        setState(() {
          if (isSelected) {
            _selected.remove(serviceName);
          } else {
            _selected.add(serviceName);
          }
          _saveSelected();
        });
      },
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: (MediaQuery.of(context).size.width - 52) / 2,
        decoration: BoxDecoration(
          color: isSelected
              ? serviceInfo.color.withOpacity(0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? serviceInfo.color
                : colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: serviceInfo.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          serviceInfo.icon,
                          color: serviceInfo.color,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? serviceInfo.color
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? serviceInfo.color
                                : colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    serviceInfo.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${serviceInfo.domains.length} доменов',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedCard(
                  onTap: () => _installAutomationForApp(serviceName),
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: serviceInfo.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupButton(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AnimatedCard(
      onTap: _selected.isEmpty ? null : _installAllSelected,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              color: colorScheme.onPrimary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Настроить автоматизацию',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Создание готовой схемы автоматизации для конкретного приложения
  Future<void> _installAutomationForApp(String appName) async {
    if (!mounted) return;

    await _triggerHaptic();

    // Показываем диалог с инструкцией
    showDialog(
      context: context,
      builder: (context) => _ModernInstructionDialog(
        appName: appName,
        isSingleApp: true,
      ),
    );
  }

  // Установка автоматизации для всех выбранных приложений
  Future<void> _installAllSelected() async {
    if (_selected.isEmpty) return;
    if (!mounted) return;

    await _triggerHaptic();

    showDialog(
      context: context,
      builder: (context) => _ModernInstructionDialog(
        appName: null,
        isSingleApp: false,
        selectedCount: _selected.length,
      ),
    );
  }

}

class ServiceInfo {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> domains;

  ServiceInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.domains,
  });
}

class _ModernInstructionDialog extends StatelessWidget {
  final String? appName;
  final bool isSingleApp;
  final int? selectedCount;

  const _ModernInstructionDialog({
    required this.appName,
    required this.isSingleApp,
    this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
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
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
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
                      Icons.download,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSingleApp
                              ? 'Установка автоматизации'
                              : 'Установка автоматизаций',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        if (isSingleApp && appName != null)
                          Text(
                            'Для: $appName',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.9),
                            ),
                          )
                        else if (!isSingleApp && selectedCount != null)
                          Text(
                            'Выбрано: $selectedCount сервисов',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Контент
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStep(
                      context,
                      '1',
                      'Откройте "Команды" → "Автоматизация" → "+ Создать"',
                      Icons.add_circle_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      context,
                      '2',
                      isSingleApp && appName != null
                          ? 'Выберите "Приложение" → "$appName" → "Открывается"'
                          : 'Выберите "Приложение" → нужное приложение → "Открывается"',
                      Icons.apps,
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      context,
                      '3',
                      'Нажмите "Добавить действие" → в поиске введите "Open URLs" или "Открыть URL" → выберите найденное действие',
                      Icons.search,
                    ),
                    const SizedBox(height: 16),
                    _buildUrlCard(context, 'cryptonvpn://connect'),
                    const SizedBox(height: 16),
                    _buildStep(
                      context,
                      '4',
                      'Вставьте скопированный выше URL в поле действия → Отключите "Запрашивать перед запуском" → "Готово"',
                      Icons.check_circle_outline,
                    ),
                    if (!isSingleApp) ...[
                      const SizedBox(height: 16),
                      _buildStep(
                        context,
                        '5',
                        'Повторите для каждого выбранного приложения',
                        Icons.repeat,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildHelpCard(context),
                  ],
                ),
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
                      onPressed: () => Navigator.pop(context),
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
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      onPressed: () {
                        Navigator.pop(context);
                        _openShortcutsApp();
                      },
                      label: const Text('Открыть Команды'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
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

  Widget _buildStep(BuildContext context, String number, String text, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlCard(BuildContext context, String url) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.link,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              url,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedCard(
            onTap: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('URL скопирован в буфер обмена'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: colorScheme.surface,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.copy,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Полезная информация',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            context,
            'Если действие не найдено:',
            'Попробуйте поискать: "Open URLs", "Открыть URL", "URL" или найдите в категории "Web" / "Интернет".',
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: colorScheme.outline.withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            context,
            'Для отключения VPN:',
            'Создайте аналогичную автоматизацию, но выберите "Закрывается" и используйте URL:',
          ),
          const SizedBox(height: 8),
          _buildUrlCard(context, 'cryptonvpn://disconnect'),
        ],
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, String title, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Future<void> _openShortcutsApp() async {
    final uri = Uri.parse('shortcuts://');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
