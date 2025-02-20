import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart';
import 'package:vpn/mobile/ui/widgets/drawers/balance_drawer.dart';
import 'package:vpn/mobile/ui/widgets/drawers/balance_drawer.dart';
import 'package:vpn/mobile/ui/widgets/drawers/profile_drawer.dart';
import 'package:vpn/mobile/ui/widgets/server_list.dart';
import 'package:vpn/mobile/ui/widgets/vpn_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:window_manager/window_manager.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String email = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                elevation: 0,
                backgroundColor: theme.primaryColor,
                leading: IconButton(
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  icon: Icon(Iconsax.arrow_left_2,
                      color: theme.textTheme.bodyLarge?.color),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Iconsax.arrow_right_3,
                        color: theme.textTheme.bodyLarge?.color),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                ],
              ),
              drawer: ProfileDrawer(email: email),
              endDrawer: BalanceIndicator(),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.scaffoldBackgroundColor,
                      theme.cardColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // ElevatedButton(
                      //     onPressed: () async {
                      //       AppWindow appWindow = AppWindow();
                      //       await appWindow.hide();
                      //     },
                      //     child: Text('Minimize Me')),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  VpnButton(),
                                  SizedBox(height: 30),
                                  ServerList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: theme.primaryColor,
            ),
          );
        });
  }
}
