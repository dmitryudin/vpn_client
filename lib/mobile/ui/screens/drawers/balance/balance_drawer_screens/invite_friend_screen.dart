import 'package:auth_feature/data/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';

class InviteFriendScreen extends StatefulWidget {
  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  String? inviteCode;
  final dio = Dio();

  Future<void> _generateInviteCode() async {
    try {
      final userData = await getUserData();
      final response = await dio.post(
        'http://109.196.101.63:8000/api/create_invite/',
        options: Options(
          headers: {
            'Authorization': 'Token ${userData.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {'email': userData.email},
      );

      if (response.statusCode == 201) {
        setState(() {
          inviteCode = response.data['invite_code'].toString();
        });
        _showInviteDialog();
      }
    } catch (e) {
      print('Error generating invite code: $e');
    }
  }

  void _showInviteDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Ваш код приглашения',
            style: TextStyle(color: theme.colorScheme.onPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Код: $inviteCode',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inviteCode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Код скопирован')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.share, color: theme.colorScheme.onPrimary),
            label: Text(
              'Поделиться',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            onPressed: () {
              Share.share('Используйте мой код приглашения: $inviteCode');
            },
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Закрыть',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Пригласить друга'),
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down_sharp),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Приглашайте друзей и получайте бонусы!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              SizedBox(height: 30),
              _buildBenefitCard(
                theme,
                icon: Icons.timer,
                title: '5 дней бесплатного VPN',
                description: 'За каждого приглашенного друга',
              ),
              SizedBox(height: 20),
              _buildBenefitCard(
                theme,
                icon: Icons.security,
                title: 'Безопасный доступ',
                description: 'Ваши друзья получат защищенное соединение',
              ),
              SizedBox(height: 20),
              _buildBenefitCard(
                theme,
                icon: Icons.speed,
                title: 'Высокая скорость',
                description: 'Доступ к премиум серверам для вас и друзей',
              ),
              SizedBox(height: 40),
              Text(
                'Как это работает:',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              _buildStepCard(
                  theme, '1', 'Сгенерируйте уникальный код приглашения'),
              _buildStepCard(theme, '2', 'Отправьте код другу'),
              _buildStepCard(theme, '3',
                  'Получите 5 дней бесплатного VPN после регистрации друга'),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _generateInviteCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Сгенерировать код приглашения',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.onPrimary),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text(description,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(ThemeData theme, String step, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 16, color: theme.colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }
}
