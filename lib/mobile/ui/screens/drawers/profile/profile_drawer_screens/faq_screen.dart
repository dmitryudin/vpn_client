import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FAQScreen extends StatefulWidget {
  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    bool isExpanded = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
        elevation: 0,
        backgroundColor: colorScheme.primary,
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
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          FAQItem(
            question: 'Как мне зарегистрироваться?',
            answer:
                'Вы можете зарегистрироваться, нажав на кнопку "Зарегистрироваться" на главном экране.',
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          FAQItem(
            question: 'Как сбросить пароль?',
            answer:
                'На странице входа нажмите на "Забыли пароль?" и следуйте инструкциям.',
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          // Добавьте больше вопросов и ответов по необходимости
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const FAQItem({
    required this.question,
    required this.answer,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        shape: Border(),
        title: Text(
          question,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
