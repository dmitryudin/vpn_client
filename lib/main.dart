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

    FlutterVpn.onStateChanged.listen((s) => setState(() => state = s));
    periodicUpdate();
    super.initState();
  }

  void periodicUpdate() {
    Timer(Duration(milliseconds: 7000), () async {
      setState(() {
        if (state == FlutterVpnState.disconnected) {
          connected = false;
        } else {
          connected = true;
        }
        if (colorflag) {
          colorflag = false;
          _color = Colors.blue;
        } else {
          _color = Color.fromARGB(255, 10, 69, 117);
          colorflag = true;
        }

        // Create a random number generator.
        final random = Random();

        // Generate a random width and height.

        // Generate a random color.
        //  _color = Color.fromRGBO(
        //   random.nextInt(256),
        //    random.nextInt(256),
        ////   random.nextInt(256),
        //    1,
        // );
      });
      print('color updated');
      periodicUpdate();
    });
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
            connected
                ? Text(
                    'Статус: подключено',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  )
                : Text(
                    'Статус: отключено',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                if (connected == false) {
                  FlutterVpn.connectIkev2EAP(
                    server: 'thefircoffe.ddns.net',
                    username: 'vpn1',
                    password: '9174253q',
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
