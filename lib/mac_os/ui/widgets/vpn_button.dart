import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/state.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_event.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_state.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

class VpnButton extends StatefulWidget {
  @override
  _VpnButtonState createState() => _VpnButtonState();
}

class _VpnButtonState extends State<VpnButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Color _colortap = Colors.grey;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _getButtonChild(FlutterVpnState state) {
    switch (state) {
      case FlutterVpnState.disconnected:
        return ClipOval(
          child: Image.asset(
            'assets/icons/pixel.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
      case FlutterVpnState.connecting:
        return ClipOval(
          child: Image.asset(
            'assets/icons/image.gif',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
      case FlutterVpnState.connected:
        return ClipOval(
          child: Image.asset(
            'assets/icons/connected.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
      default:
        return ClipOval(
          child: Image.asset(
            'assets/icons/pixel.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VpnBloc, VpnState>(
      builder: (context, state) {
        _colortap = state.connectionState == FlutterVpnState.connected
            ? const Color.fromARGB(255, 118, 16, 134)
            : Colors.grey;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                // await Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => Scaffold(
                //               body: Align(
                //                 alignment: Alignment.bottomCenter,
                //                 child: AdWidget(
                //                     bannerAd: BannerAd(
                //                         adUnitId: 'R-M-13885939-1',
                //                         adSize: BannerAdSize.inline(
                //                             width: MediaQuery.of(context)
                //                                 .size
                //                                 .width
                //                                 .toInt(),
                //                             maxHeight: MediaQuery.of(context)
                //                                 .size
                //                                 .height
                //                                 .toInt()))),
                //               ),
                //             )));

                if (state.connectionState == FlutterVpnState.disconnected) {
                  context.read<VpnBloc>().add(ConnectVpn());
                } else if (state.connectionState == FlutterVpnState.connected ||
                    state.connectionState == FlutterVpnState.connecting) {
                  context.read<VpnBloc>().add(DisconnectVpn());
                }
              },
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _colortap,
                      borderRadius: BorderRadius.circular(300),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _colortap.withOpacity(_animationController.value),
                          offset: Offset(0.0, 0.0),
                          blurRadius: 30.0,
                        ),
                      ],
                    ),
                    child: _getButtonChild(state.connectionState),
                  );
                },
              ),
            ),
            SizedBox(height: 60),
            Text(
              state.status,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
