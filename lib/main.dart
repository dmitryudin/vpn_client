import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter_vpn/state.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  var state = FlutterVpnState.disconnected;
  String status = 'Подключить';

  CharonErrorState? charonState = CharonErrorState.NO_ERROR;
  Color _color = Colors.blue;
  Color _colortap = Colors.grey;
  bool connected = false;
  bool colorflag = false;

  var icon = Icon(
    Icons.power_off,
    size: 100,
  );
  @override
  void initState() {
    FlutterVpn.prepare();

    FlutterVpn.onStateChanged.listen((s) => setState(() {
          state = s;
          switch (state) {
            case FlutterVpnState.disconnected:
              connected = false;
              status = 'Отключено';
              break;
            case FlutterVpnState.connecting:
              status = 'Подключение';
              connected = false;
              break;
            case FlutterVpnState.connected:
              status = 'Подключено';
              connected = true;
              break;
            case FlutterVpnState.disconnecting:
              connected = true;
              status = 'Отключение';
              break;

            case FlutterVpnState.error:
              status = 'Ошибка';
              connected = false;
              break;
          }
          setState(() {
            if (colorflag) {
              colorflag = false;
              _color = Colors.blue;
            } else {
              _color = Color.fromARGB(255, 10, 69, 117);
              colorflag = true;
            }
          });
        }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //double width = MediaQuery.of(context).size.width;
    //double height = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
          body: AnimatedContainer(
        // Use the properties stored in the State class.
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _color,
          // borderRadius: _borderRadius,
        ),
        // Define how long the animation should take.
        duration: const Duration(seconds: 7),
        // Provide an optional curve to make the animation feel smoother.
        curve: Curves.slowMiddle,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // padding: const EdgeInsets.all(12),
          children: <Widget>[
            Text(
              'Статус: $status',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                if (connected == false) {
                  FlutterVpn.connectIkev2EAP(
                    server: 'vpnappsuper.ddns.net',
                    username: 'vpn',
                    password: '9174253',
                  );
                  connected = true;
                  setState(() {
                    icon = Icon(
                      Icons.power,
                      size: 200,
                    );
                    _colortap = Colors.green;
                  });
                } else {
                  FlutterVpn.disconnect();
                  connected = false;
                  setState(() {
                    icon = Icon(
                      Icons.power_off,
                      size: 200,
                    );
                    _colortap = Colors.grey;
                  });
                }
              },
              child: AnimatedContainer(
                  // Use the properties stored in the State class.
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: _colortap,
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: [
                      BoxShadow(
                        color: _colortap,
                        offset: Offset(0.0, 0.0), //(x,y)
                        blurRadius: 30.0,
                      ),
                    ],
                  ),
                  // Define how long the animation should take.
                  duration: const Duration(seconds: 1),
                  // Provide an optional curve to make the animation feel smoother.
                  curve: Curves.slowMiddle,
                  child: icon),
            ),
          ],
        ),
      )),
    );
  }
}
