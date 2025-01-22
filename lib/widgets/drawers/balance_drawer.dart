import 'package:flutter/material.dart';

class BalanceDrawer extends StatelessWidget {
  final int balance;

  const BalanceDrawer({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.blue,
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  'Баланс',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 150,
                  height: 150,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: balance / 10,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      Center(
                        child: Text(
                          '$balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'У вас осталось $balance криптокойнов',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Купить безлимитную подписку'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Оценить и получить 5 койнов'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Пригласить друга (+5 койнов)'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
