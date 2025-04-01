import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    bool isExpanded = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Поддержка'),
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
              'Свяжитесь с нами',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Если у вас есть вопросы или вам нужна помощь, пожалуйста, свяжитесь с нашей службой поддержки.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Действие для связи с поддержкой
              },
              child: Text('Написать в поддержку'),
            ),
          ],
        ),
      ),
    );
  }
}
