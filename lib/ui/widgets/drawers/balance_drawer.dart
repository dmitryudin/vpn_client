import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/bloc/screen_state_bloc.dart';

class BalanceIndicator extends StatefulWidget {
  const BalanceIndicator({Key? key}) : super(key: key);

  @override
  _BalanceIndicatorState createState() => _BalanceIndicatorState();
}

class _BalanceIndicatorState extends State<BalanceIndicator> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ScreenStateBloc, ScreenStateState>(
      builder: (context, state) {
        int balance;

        switch (state.runtimeType) {
          case ScreenStateLoaded:
            balance = ((state.rootModel?.user_info?.balance) ?? 0).toInt();
            break;
          default:
            balance = 0;
        }

        return Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        'Баланс',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildBalanceCircle(balance, colorScheme),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildMenuSection(colorScheme),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCircle(int balance, ColorScheme colorScheme) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: balance / 10,
              strokeWidth: 15,
              backgroundColor: colorScheme.onPrimary.withOpacity(0.24),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$balance',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'дней',
                style: TextStyle(
                  color: colorScheme.onPrimary.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        children: [
          _buildMenuItem(
            icon: Icons.shopping_cart,
            title: 'Купить безлимитную подписку',
            onTap: () {},
            colorScheme: colorScheme,
          ),
          _buildMenuItem(
            icon: Icons.star,
            title: 'Оценить и получить 5 дней',
            onTap: () {},
            colorScheme: colorScheme,
          ),
          _buildMenuItem(
            icon: Icons.person_add,
            title: 'Пригласить друга 5 дней',
            onTap: () {},
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: colorScheme.onBackground,
        ),
      ),
      onTap: onTap,
    );
  }
}
