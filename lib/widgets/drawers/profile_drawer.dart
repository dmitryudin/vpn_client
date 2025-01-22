import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../localization/app_localization.dart';

class ProfileDrawer extends StatelessWidget {
  final String email;
  final String languageCode;
  const ProfileDrawer({required this.email, this.languageCode = 'ru'});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                email[0].toUpperCase(),
                style: TextStyle(fontSize: 24, color: Colors.blue),
              ),
            ),
            accountName: Text("Ваша почта:"),
            accountEmail: Text(email),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(AppLocalization.translate('settings', languageCode)),
            onTap: () {
              context.push('/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Оценить приложение'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('О нас'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text('FAQ'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.support),
            title: Text('Поддержка'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
