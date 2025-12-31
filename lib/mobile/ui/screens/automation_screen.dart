import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutomationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        title: Text(
          'Автоматизация',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: colorScheme.background,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _ShortcutsAutomationSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutsAutomationSection extends StatefulWidget {
  @override
  State<_ShortcutsAutomationSection> createState() => _ShortcutsAutomationSectionState();
}

class _ShortcutsAutomationSectionState extends State<_ShortcutsAutomationSection> {
  static const _prefsKeySelected = 'shortcuts_selected_services_v1';

  final Map<String, List<String>> _serviceDomains = const {
    'YouTube': [
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
    'Instagram': [
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
    'Facebook': [
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
    'TikTok': [
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
    'Telegram': [
      'telegram.org',
      't.me',
      'web.telegram.org',
      'telegram.me',
      'core.telegram.org',
    ],
    'Twitter (X)': [
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
    'LinkedIn': [
      'linkedin.com',
      'www.linkedin.com',
      'm.linkedin.com',
      'licdn.com',
      'media.licdn.com',
      'static.licdn.com',
    ],
    'Reddit': [
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
    'Twitch': [
      'twitch.tv',
      'www.twitch.tv',
      'm.twitch.tv',
      'static-cdn.jtvnw.net',
      'vod-secure.twitch.tv',
      'usher.ttvnw.net',
      'api.twitch.tv',
      'clips-media-assets2.twitch.tv',
    ],
    'GitHub': [
      'github.com',
      'www.github.com',
      'githubusercontent.com',
      'raw.githubusercontent.com',
      'avatars.githubusercontent.com',
      'github.io',
    ],
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
          ..addAll(list.where(_serviceDomains.containsKey));
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

  Future<void> _showSetupDialog() async {
    if (!mounted || _selected.isEmpty) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colorScheme.surface,
        title: Row(
        children: [
            Icon(Icons.settings_outlined, color: colorScheme.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
                'Настройка автоматизации',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
          ),
        ],
      ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Выбрано: ${_selected.length} сервисов',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Пошаговая инструкция:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12),
              _buildStep(context, '1', 'Откройте приложение "Команды"'),
              _buildStep(context, '2', 'Перейдите на вкладку "Автоматизация"'),
              _buildStep(context, '3', 'Нажмите "+ Создать автоматизацию"'),
              _buildStep(context, '4', 'Выберите "Приложение"'),
              _buildStep(
                context,
                '5',
                'Выберите нужное приложение (YouTube, Instagram и т.д.)',
              ),
              _buildStep(context, '6', 'Выберите "Открывается"'),
              _buildStep(context, '7', 'Нажмите "Добавить действие"'),
              _buildStep(context, '8', 'Найдите и выберите "Открыть URL"'),
              _buildStep(context, '9', 'Введите: cryptonvpn://connect'),
              _buildStep(
                context,
                '10',
                'Отключите "Запрашивать перед запуском"',
              ),
              _buildStep(context, '11', 'Нажмите "Готово"'),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                            'Важно:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                            'Повторите для каждого приложения. Для отключения VPN при закрытии используйте cryptonvpn://disconnect',
                      style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.open_in_new, size: 18),
            onPressed: () {
              Navigator.pop(context);
              _openShortcutsApp();
            },
            label: Text('Открыть Команды'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openShortcutsApp() async {
    final uri = Uri.parse('shortcuts://');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Не удалось открыть приложение "Команды". Установите его из App Store.',
          ),
          backgroundColor: colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surface,
        child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            children: [
              Container(
                  padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                    Icons.auto_awesome,
                    color: colorScheme.primary,
                    size: 24,
                  ),
              ),
              SizedBox(width: 16),
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
                    SizedBox(height: 4),
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
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
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
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Этот метод работает надежно. Создайте автоматизацию в приложении "Команды" для каждого нужного приложения.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
              ),
            ],
          ),
        ),
            SizedBox(height: 24),
              Text(
              'Выберите сервисы:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              ),
              SizedBox(height: 16),
            if (_loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Загрузка сервисов…',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
          ),
        ],
      ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: _serviceDomains.keys.map((name) {
                    final checked = _selected.contains(name);
                    final isLast = name == _serviceDomains.keys.last;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (checked) {
                            _selected.remove(name);
                          } else {
                            _selected.add(name);
                          }
                          _saveSelected();
                        });
                      },
                      borderRadius: BorderRadius.vertical(
                        bottom: isLast ? Radius.circular(12) : Radius.zero,
                        top: name == _serviceDomains.keys.first
                            ? Radius.circular(12)
                            : Radius.zero,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: isLast
                                ? BorderSide.none
                                : BorderSide(
                                    color: colorScheme.outline.withOpacity(0.1),
                                    width: 1,
                                  ),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                ),
                child: Row(
                  children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: checked
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  width: 2,
                                ),
                                color: checked
                                    ? colorScheme.primary
                                    : Colors.transparent,
                              ),
                              child: checked
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: colorScheme.onPrimary,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 16),
                    Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${_serviceDomains[name]!.length} доменов',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
                    );
                  }).toList(),
                ),
              ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.settings_outlined, size: 20),
                label: Text(
                  'Настроить автоматизацию',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selected.isEmpty ? null : _showSetupDialog,
              ),
            ),
            if (_selected.isNotEmpty) ...[
              SizedBox(height: 12),
              Center(
                child: Text(
                  'Выбрано: ${_selected.length} из ${_serviceDomains.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
