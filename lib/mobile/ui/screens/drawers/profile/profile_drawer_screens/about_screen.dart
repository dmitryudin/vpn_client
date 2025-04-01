import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    bool isExpanded = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('О нас'),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: AnimatedRotation(
            duration: Duration(milliseconds: 300),
            turns: isExpanded ? 0.5 : 0,
            child: Icon(Icons.keyboard_arrow_down_outlined,
                color: colorScheme.onPrimary),
          ),
          onPressed: () {
            setState(() {
              isExpanded = !isExpanded;
            });
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'О нашем приложении',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Мы создаем инновационные решения для улучшения вашей повседневной жизни. Наше приложение разработано с любовью и заботой о каждом пользователе.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
