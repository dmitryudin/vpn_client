import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/ui/widgets/drawers/balance_drawer.dart';
import 'package:vpn/ui/widgets/drawers/balance_drawer.dart';
import 'package:vpn/ui/widgets/drawers/profile_drawer.dart';
import 'package:vpn/ui/widgets/server_list.dart';
import 'package:vpn/ui/widgets/vpn_button.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String email = '';

  final int balance = 10;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (email.isEmpty) {
              email = snapshot.data!.getString('user_email') ?? '';
            }
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  icon: Icon(Iconsax.arrow_left_2),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Iconsax.arrow_right_3),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
              drawer: ProfileDrawer(email: email),
              endDrawer: BalanceIndicator(),
              body: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
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
                    ),
                  ],
                ),
              ),
            );
          }
          return CircularProgressIndicator();
        });
  }
}
