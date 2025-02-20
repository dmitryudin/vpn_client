import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChangeTariffScreen extends StatefulWidget {
  @override
  _ChangeTariffScreenState createState() => _ChangeTariffScreenState();
}

class _ChangeTariffScreenState extends State<ChangeTariffScreen> {
  int? _selectedTariffId; // Добавить эту строку

  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Премиум подписка'),
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down_sharp),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок и описание
              Text(
                'Откройте полный доступ',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Карточки с преимуществами
              _buildFeatureCard(
                  icon: Icons.speed,
                  title: 'Автоматизация',
                  description:
                      'Автоматическое подключение VPN при запуске приложений'),
              _buildFeatureCard(
                  icon: Icons.block,
                  title: 'Без рекламы',
                  description: 'Полное отключение всей рекламы в приложении'),
              _buildFeatureCard(
                  icon: Icons.language,
                  title: 'Все сервера',
                  description:
                      'Доступ ко всем серверам в более чем 30 странах'),

              SizedBox(height: 24),

              // Тарифы
              Card(
                child: RadioListTile<int>(
                  title: Text('Месячная подписка'),
                  subtitle: Text('499 ₽/месяц'),
                  value: 0,
                  groupValue: _selectedTariffId,
                  onChanged: (value) =>
                      setState(() => _selectedTariffId = value),
                ),
              ),

              Card(
                child: RadioListTile<int>(
                  title: Text('Годовая подписка'),
                  subtitle: Text('3999 ₽/год (экономия 50%)'),
                  value: 1,
                  groupValue: _selectedTariffId,
                  onChanged: (value) =>
                      setState(() => _selectedTariffId = value),
                ),
              ),

              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _selectedTariffId != null ? _confirmSelection : null,
                child: Text('Оформить подписку'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSelection() {
    // Добавьте здесь логику подтверждения выбора тарифа
  }
  Widget _buildFeatureCard(
      {required IconData icon,
      required String title,
      required String description}) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
