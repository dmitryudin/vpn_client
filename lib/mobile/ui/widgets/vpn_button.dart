import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_event.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_state.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'package:vibration/vibration.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../../utils/bloc/screen_state_bloc.dart';
import '../screens/help_screens/without_add.dart';

class VpnButton extends StatefulWidget {
  @override
  _VpnButtonState createState() => _VpnButtonState();
}

class _VpnButtonState extends State<VpnButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Color _colortap = Colors.grey;
  late final Future<InterstitialAdLoader> _adLoader;
  InterstitialAd? _ad;
  late int _vpnPressCount;
  bool _isBannerShown = false;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    MobileAds.initialize();
    _adLoader = _createInterstitialAdLoader();
    _loadInterstitialAd();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vpnPressCount = prefs.getInt('vpnPressCount') ?? 0;
      _isBannerShown = prefs.getBool('isBannerShown') ?? false;
    });
  }

  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vpnPressCount++;
      prefs.setInt('vpnPressCount', _vpnPressCount);
    });
  }

  Future<InterstitialAdLoader> _createInterstitialAdLoader() {
    return InterstitialAdLoader.create(
      onAdLoaded: (InterstitialAd interstitialAd) {
        _ad = interstitialAd;
      },
      onAdFailedToLoad: (error) {
        // Обработка ошибки загрузки
      },
    );
  }

  Future<void> _loadInterstitialAd() async {
    final adLoader = await _adLoader;
    await adLoader.loadAd(
      adRequestConfiguration: AdRequestConfiguration(
        adUnitId: 'R-M-13885939-1',
      ),
    );
  }

  Future<void> _showAd() async {
    if (_ad != null) {
      _ad!.setAdEventListener(
        eventListener: InterstitialAdEventListener(
            onAdShown: () {},
            onAdFailedToShow: (error) {
              _ad?.destroy();
              _ad = null;
              _loadInterstitialAd();
            },
            onAdClicked: () {},
            onAdDismissed: () {
              _ad?.destroy();
              _ad = null;
              _loadInterstitialAd();
            },
            onAdImpression: (impressionData) {}),
      );
      await _ad!.show();
      await _ad!.waitForDismiss();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ad?.destroy();
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

  int _getCurrentTariffId(BuildContext context) {
    final screenState = context.read<ScreenStateBloc>().state;
    if (screenState is ScreenStateLoaded) {
      return screenState.rootModel?.user_info?.current_tarif_id ?? 1;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VpnBloc, VpnState>(
      listener: (context, state) {
        // Отслеживаем изменение состояния на "Подключено"
        if (state.connectionState == FlutterVpnState.connected) {
          // Воспроизводим вибрацию успеха
          Haptics.vibrate(HapticsType.success);
        }
      },
      child: BlocBuilder<VpnBloc, VpnState>(
        builder: (context, state) {
          _colortap = state.connectionState == FlutterVpnState.connected
              ? const Color.fromARGB(255, 118, 16, 134)
              : Colors.grey;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  if (state.connectionState == FlutterVpnState.disconnected) {
                    final currentTariffId = _getCurrentTariffId(context);
                    final prefs = await SharedPreferences.getInstance();

                    if (currentTariffId == 1) {
                      // Увеличиваем счетчик нажатий
                      int pressCount = prefs.getInt('vpnPressCount') ?? 0;
                      pressCount++;
                      await prefs.setInt('vpnPressCount', pressCount);

                      // Проверяем условия показа баннера (каждые 2 нажатия)
                      if (pressCount % 3 == 0) {
                        // Показываем баннер и ждем результат
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WithoutAdd()),
                        );

                        // Если баннер закрыт - показываем рекламу и сбрасываем счетчик
                        if (result == 'closed') {
                          await _showAd();
                          await prefs.setInt(
                              'vpnPressCount', 0); // Сброс счетчика
                        }
                      } else {
                        // Показываем рекламу для нечетных нажатий
                        await _showAd();
                      }
                    }

                    // Вибрация для всех случаев
                    if (await Haptics.canVibrate()) {
                      if (Platform.isIOS) {
                        await Haptics.vibrate(HapticsType.light);
                      } else {
                        Vibration.vibrate(duration: 100);
                      }
                    }

                    // Подключение VPN
                    context.read<VpnBloc>().add(ConnectVpn());
                  } else {
                    // Обработка отключения
                    if (await Haptics.canVibrate()) {
                      if (Platform.isIOS) {
                        await Haptics.vibrate(HapticsType.heavy);
                      } else {
                        Vibration.vibrate(pattern: [100, 100, 100, 100]);
                      }
                    }
                    context.read<VpnBloc>().add(DisconnectVpn());
                  }
                },
                // onTap: () async {
                //   if (state.connectionState == FlutterVpnState.disconnected) {
                //     final currentTariffId = _getCurrentTariffId(context);

                //     if (currentTariffId == 1) {
                //       await _incrementCounter();

                //       if (_vpnPressCount == 2 && !_isBannerShown) {
                //         final result = await Navigator.push(
                //           context,
                //           MaterialPageRoute(builder: (context) => WithoutAdd()),
                //         );

                //         if (result == 'closed') {
                //           await _showAd();
                //           final prefs = await SharedPreferences.getInstance();
                //           prefs.setBool('isBannerShown', true);
                //         }
                //       } else {
                //         await _showAd();
                //       }
                //     }

                //     // Остальной код вибрации и подключения
                //     context.read<VpnBloc>().add(ConnectVpn());
                //   } else {
                //     // Обработка отключения
                //   }
                // },
                //               onTap: () async {
                //   if (state.connectionState == FlutterVpnState.disconnected) {
                //     final currentTariffId = _getCurrentTariffId(context);

                //     if (currentTariffId == 1) {
                //       await _showAd();
                //     }

                //     // Вибрация при подключении
                //     if (await Haptics.canVibrate()) {
                //       if (Platform.isIOS) {
                //         // Используем Taptic Engine для iOS (вибрация как при включении беззвучного режима)
                //         await Haptics.vibrate(HapticsType.light);
                //       } else {
                //         // Стандартная вибрация для Android
                //         Vibration.vibrate(duration: 100);
                //       }
                //     }

                //     context.read<VpnBloc>().add(ConnectVpn());
                //   } else {
                //     // Вибрация при отключении
                //     if (await Haptics.canVibrate()) {
                //       if (Platform.isIOS) {
                //         // Используем Taptic Engine для iOS (вибрация как при выключении беззвучного режима)
                //         await Haptics.vibrate(HapticsType.heavy);
                //       } else {
                //         // Стандартная вибрация для Android
                //         Vibration.vibrate(pattern: [100, 100, 100, 100]);
                //       }
                //     }

                //     context.read<VpnBloc>().add(DisconnectVpn());
                //   }
                // },
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
                            color: _colortap
                                .withOpacity(_animationController.value),
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
      ),
    );
  }
}
