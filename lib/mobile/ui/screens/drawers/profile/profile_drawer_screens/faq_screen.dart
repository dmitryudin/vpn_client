import 'package:flutter/material.dart';
import 'package:vpn/mobile/ui/widgets/animated_back_button.dart';
import 'package:vpn/mobile/ui/widgets/animated_card.dart';
import 'package:vpn/mobile/ui/widgets/fade_in_widget.dart';

class FAQScreen extends StatefulWidget {
  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Как мне зарегистрироваться?',
      answer:
          'Вы можете зарегистрироваться, нажав на кнопку "Зарегистрироваться" на главном экране или в меню профиля. Вам потребуется указать email, пароль и инвайт-код.',
    ),
    FAQItem(
      question: 'Как сбросить пароль?',
      answer:
          'Если вы забыли пароль, обратитесь в службу поддержки через раздел "Поддержка" в меню приложения. Наша команда поможет восстановить доступ к аккаунту.',
    ),
    FAQItem(
      question: 'Как работает VPN?',
      answer:
          'VPN создает зашифрованное соединение между вашим устройством и нашими серверами. Весь ваш интернет-трафик проходит через это защищенное соединение, обеспечивая конфиденциальность и безопасность.',
    ),
    FAQItem(
      question: 'Сколько устройств можно подключить?',
      answer:
          'Количество устройств зависит от вашего тарифа. Базовый тариф позволяет подключить одно устройство, премиум тариф - до трех устройств одновременно.',
    ),
    FAQItem(
      question: 'Как выбрать сервер?',
      answer:
          'На главном экране нажмите на карточку с текущим сервером. Откроется список доступных серверов. Выберите нужный сервер из списка.',
    ),
    FAQItem(
      question: 'Что такое автоматизация VPN?',
      answer:
          'Автоматизация позволяет автоматически включать VPN при открытии определенных приложений. Это настраивается через приложение "Команды" на iOS.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: textTheme.titleLarge?.copyWith(
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
              colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            FadeInWidget(
              delay: const Duration(milliseconds: 50),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
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
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
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
                            'Часто задаваемые вопросы',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Найдите ответы на популярные вопросы',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              _faqItems.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == _faqItems.length - 1 ? 0 : 12),
                child: FadeInWidget(
                  delay: Duration(milliseconds: 100 + (index * 50)),
                  child: FAQItemWidget(
                    faqItem: _faqItems[index],
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}

class FAQItemWidget extends StatefulWidget {
  final FAQItem faqItem;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const FAQItemWidget({
    Key? key,
    required this.faqItem,
    required this.colorScheme,
    required this.textTheme,
  }) : super(key: key);

  @override
  State<FAQItemWidget> createState() => _FAQItemWidgetState();
}

class _FAQItemWidgetState extends State<FAQItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: widget.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.colorScheme.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.faqItem.question,
                          style: widget.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: widget.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        widget.faqItem.answer,
                        style: widget.textTheme.bodyMedium?.copyWith(
                          color: widget.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
