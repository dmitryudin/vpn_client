import 'package:auth_feature/auth_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/state.dart';
import 'package:get_it/get_it.dart';
import 'package:vpn/utils/bloc/screen_state_bloc.dart';
import 'package:vpn/utils/vpn_bloc/vpn_bloc.dart';
import 'package:vpn/utils/vpn_bloc/vpn_event.dart';

import '../../utils/vpn_bloc/vpn_state.dart';

class ServerList extends StatefulWidget {
  final List<String>? servers;

  const ServerList({Key? key, this.servers}) : super(key: key);

  @override
  _ServerListState createState() => _ServerListState();
}

class _ServerListState extends State<ServerList> {
  String? selectedServer;
  @override
  void initState() {
    super.initState();
    context.read<ScreenStateBloc>().add(LoadServerList());
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: BlocBuilder<ScreenStateBloc, ScreenStateState>(
        builder: (context, state) {
      return BlocBuilder<VpnBloc, VpnState>(
        builder: (context, vpnState) {
          bool isEnabled =
              vpnState.connectionState != FlutterVpnState.connected;
          if (state is ScreenStateLoaded &&
              state.rootModel?.servers?.isNotEmpty == true) {
            selectedServer ??= state.rootModel?.servers?.first.id.toString();
          }
          switch (state.runtimeType) {
            case (ScreenStateInitial):
              return const Center(child: CircularProgressIndicator());

            case (ScreenStateError):
              {
                return DropdownButton<String>(
                  value: selectedServer,
                  hint: Text('Выберите сервер'),
                  items: [],
                  onChanged: (value) {},
                );
              }
            case (ScreenStateLoaded):
              {
                return DropdownButton<String>(
                  value: selectedServer,
                  hint: Text('Выберите сервер'),
                  isExpanded: true,
                  items: state.rootModel!.servers?.map((server) {
                    return DropdownMenuItem<String>(
                      value: server.id.toString(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Флаг страны
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            child: Text(
                              getCountryFlag(server.country ?? ''),
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(server.name ?? 'No name'),
                                Text(
                                  server.ip ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Индикатор нагрузки
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            child: Icon(
                              _getLoadIcon(server.load_coef ?? 0),
                              color: _getLoadColor(server.load_coef ?? 0),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: isEnabled
                      ? (value) {
                          final server = state.rootModel?.servers?.firstWhere(
                              (element) => element.id.toString() == value);
                          BlocProvider.of<VpnBloc>(context).add(
                              ChangeServerEvent(
                                  host: server!.url ?? '',
                                  userName: server.username ?? '',
                                  password: server.password ?? ''));
                          setState(() {
                            selectedServer = value;
                          });
                        }
                      : null,
                );
              }
          }
          return DropdownButton<String>(
            value: selectedServer, // Устанавливаем выбранный элемент
            hint: Text('Выберите сервер'), // Подсказка
            items: [],
            onChanged: (value) {
              selectedServer = value;
            },
          );
        },
      );
    }));
  }
}

IconData _getLoadIcon(double loadCoef) {
  if (loadCoef < 0.4) return Icons.wifi;
  if (loadCoef < 0.7) return Icons.wifi_2_bar;
  return Icons.wifi_1_bar;
}

Color _getLoadColor(double loadCoef) {
  if (loadCoef < 0.4) return Colors.green;
  if (loadCoef < 0.7) return Colors.orange;
  return Colors.red;
}

String getCountryFlag(String countryCode) {
  // Конвертация двухбуквенного кода страны в флаг эмодзи
  final flag = countryCode.toUpperCase().replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
      );
  return flag;
}
