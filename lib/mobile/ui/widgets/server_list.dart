import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/state.dart';
import 'package:vpn/mobile/utils/bloc/screen_state_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_event.dart';
import 'package:vpn_engine/from_server/api_server/models/server_http_model.dart';

import '../../utils/vpn_bloc/vpn_state.dart';

class ServerList extends StatefulWidget {
  final List<String>? servers;

  const ServerList({Key? key, this.servers}) : super(key: key);

  @override
  _ServerListState createState() => _ServerListState();
}

class _ServerListState extends State<ServerList> {
  String? selectedServer;
  ServerHttpModel? currentServer;

  @override
  void initState() {
    super.initState();
    context.read<ScreenStateBloc>().add(LoadServerList());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: BlocBuilder<ScreenStateBloc, ScreenStateState>(
        builder: (context, state) {
          return BlocBuilder<VpnBloc, VpnState>(
            builder: (context, vpnState) {
              bool isEnabled =
                  vpnState.connectionState != FlutterVpnState.connected;

              // Инициализация currentServer из состояния
              ServerHttpModel? displayServer = currentServer;
              if (state is ScreenStateLoaded &&
                  state.rootModel?.servers?.isNotEmpty == true) {
                // Если currentServer еще не установлен, используем первый сервер
                if (displayServer == null) {
                  displayServer = state.rootModel?.servers?.first;
                  if (displayServer != null) {
                    selectedServer ??= displayServer.id.toString();
                    // Устанавливаем в VpnBloc только если там еще нет
                    if (BlocProvider.of<VpnBloc>(context).currentServer ==
                        null) {
                      BlocProvider.of<VpnBloc>(context).currentServer =
                          CurrentServer(
                        host: displayServer.url!,
                        userName: displayServer.username!,
                        password: displayServer.password!,
                      );
                    }
                    // Обновляем локальное состояние
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          currentServer = displayServer;
                        });
                      }
                    });
                  }
                } else {
                  // Обновляем selectedServer если еще не установлен
                  selectedServer ??= displayServer.id.toString();
                }
              }

              switch (state.runtimeType) {
                case ScreenStateInitial:
                  return const CupertinoActivityIndicator();

                case ScreenStateError:
                  return CupertinoButton(
                    child: Text(
                      'Ошибка загрузки серверов',
                      style: TextStyle(color: textTheme.bodyMedium?.color),
                    ),
                    onPressed: () {
                      context.read<ScreenStateBloc>().add(LoadServerList());
                    },
                  );
                case ScreenStateLoaded:
                  // Используем displayServer или первый сервер из списка
                  final serverToShow = displayServer ??
                      (state.rootModel?.servers?.isNotEmpty == true
                          ? state.rootModel!.servers!.first
                          : null);

                  if (serverToShow == null) {
                    return Text(
                      'Серверы не найдены',
                      style: TextStyle(color: textTheme.bodyMedium?.color),
                    );
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: isEnabled
                            ? () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoActionSheet(
                                      title: Text(
                                        'Выберите сервер',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      actions: [
                                        for (final server
                                            in state.rootModel!.servers!)
                                          CupertinoActionSheetAction(
                                            onPressed: () {
                                              BlocProvider.of<VpnBloc>(context)
                                                  .add(
                                                ChangeServerEvent(
                                                  host: server.url ?? '',
                                                  userName:
                                                      server.username ?? '',
                                                  password:
                                                      server.password ?? '',
                                                ),
                                              );
                                              setState(() {
                                                selectedServer =
                                                    server.id.toString();
                                                currentServer = server;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  getCountryFlag(
                                                      server.country ?? ''),
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        server.name ??
                                                            'No name',
                                                        style: TextStyle(
                                                          color: textTheme
                                                              .bodyLarge?.color,
                                                        ),
                                                      ),
                                                      Text(
                                                        server.ip ?? '',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: textTheme
                                                              .bodyMedium
                                                              ?.color,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  _getLoadIcon(
                                                      server.load_coef ?? 0),
                                                  color: _getLoadColor(
                                                    server.load_coef ?? 0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Отмена',
                                          style: TextStyle(
                                            color: colorScheme.error,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getCountryFlag(serverToShow.country ?? ''),
                                style: const TextStyle(fontSize: 20),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      serverToShow.name ?? 'No name',
                                      style: TextStyle(
                                        color: textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      serverToShow.ip ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textTheme.bodyMedium?.color
                                            ?.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _getLoadIcon(serverToShow.load_coef ?? 0),
                                color: _getLoadColor(
                                  serverToShow.load_coef ?? 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );

                default:
                  return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}

Color _getLoadColor(double loadCoef) {
  if (loadCoef < 0.4) return Colors.green;
  if (loadCoef < 0.7) return Colors.orange;
  return Colors.red;
}

IconData _getLoadIcon(double loadCoef) {
  if (loadCoef < 0.4) return Icons.wifi;
  if (loadCoef < 0.7) return Icons.wifi_2_bar;
  return Icons.wifi_1_bar;
}

String getCountryFlag(String countryCode) {
  final flag = countryCode.toUpperCase().replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
      );
  return flag;
}
