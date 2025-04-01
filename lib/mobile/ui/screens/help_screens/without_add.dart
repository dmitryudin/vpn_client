import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WithoutAdd extends StatefulWidget {
  @override
  State<WithoutAdd> createState() => WithoutAddState();
}

class WithoutAddState extends State<WithoutAdd>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // Инициализация анимации
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Начальное положение (снизу)
      end: Offset.zero, // Конечное положение (на экране)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Запуск анимации
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeBanner() {
    // Закрытие баннера с анимацией
    _controller.reverse().then((_) {
      // После завершения анимации закрытия, можно выполнить дополнительные действия
      context.pop(); // Закрыть экран
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onPrimary),
          onPressed: _closeBanner,
        ),
      ),
      body: SlideTransition(
        position: _animation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 64,
                  color: colorScheme.primary,
                ),
                SizedBox(height: 20),
                Text(
                  'Вам не нужно каждый раз смотреть рекламу!',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Просто зарегистрируйтесь через свою почту, и вы сможете пользоваться приложением без рекламы.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Переход на экран регистрации
                    context.push('/auth');
                  },
                  child: Text('Зарегистрироваться'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
