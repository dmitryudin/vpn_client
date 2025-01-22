import 'package:flutter/material.dart';
import 'package:vpn/utils/vpn_service.dart';

class VpnButton extends StatefulWidget {
  @override
  _VpnButtonState createState() => _VpnButtonState();
}

class _VpnButtonState extends State<VpnButton> {
  bool connected = false;
  bool connecting = false;
  Color _colortap = Colors.grey;
  Icon icon = Icon(
    Icons.power_off,
    size: 100,
  );
  String connectionStatus = 'Отключено';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            if (!connected && !connecting) {
              setState(() {
                connecting = true;
                connectionStatus = 'Подключение';
              });
              await VpnService.connect();
              setState(() {
                connected = true;
                connecting = false;
                icon = Icon(
                  Icons.power,
                  size: 200,
                );
                _colortap = Colors.green;
                connectionStatus = 'Подключено';
              });
            } else if (connected) {
              VpnService.disconnect();
              setState(() {
                connected = false;
                icon = Icon(
                  Icons.power_off,
                  size: 200,
                );
                _colortap = Colors.grey;
                connectionStatus = 'Отключено';
              });
            }
          },
          child: AnimatedContainer(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: _colortap,
              borderRadius: BorderRadius.circular(300),
              boxShadow: [
                BoxShadow(
                  color: _colortap,
                  offset: Offset(0.0, 0.0),
                  blurRadius: 30.0,
                ),
              ],
            ),
            duration: const Duration(seconds: 1),
            curve: Curves.slowMiddle,
            child: icon,
          ),
        ),
        SizedBox(height: 20),
        Text(
          connectionStatus,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
