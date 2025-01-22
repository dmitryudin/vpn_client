import 'package:flutter/material.dart';
import 'package:vpn/widgets/drawers/balance_drawer.dart';
import 'package:vpn/widgets/drawers/profile_drawer.dart';
import 'package:vpn/widgets/server_list.dart';
import 'package:vpn/widgets/vpn_button.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String email = "user@example.com"; // Добавьте email
  final int balance = 10; // Добавьте начальный баланс
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      drawer: ProfileDrawer(email: email),
      endDrawer: BalanceDrawer(balance: balance),
      body: Column(
        children: [
          SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VpnButton(),
                  SizedBox(height: 20),
                  ServerList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
