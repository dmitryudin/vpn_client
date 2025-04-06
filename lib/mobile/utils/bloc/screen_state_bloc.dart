import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/mobile/internal.dart';
import 'package:vpn_engine/from_server/api_server/models/free_server_model.dart';
import 'package:vpn_engine/from_server/api_server/models/root_model.dart';
import 'package:vpn_engine/from_server/api_server/models/server_http_model.dart';
import 'package:vpn_engine/from_server/api_server/models/tariff_http_model.dart';
import 'package:vpn_engine/from_server/api_server/models/user_http_model.dart';
import 'package:vpn_engine/from_server/server_info_model.dart';

part 'screen_state_event.dart';
part 'screen_state_state.dart';

class ScreenStateBloc extends Bloc<ScreenStateEvent, ScreenStateState> {
  ScreenStateBloc() : super(ScreenStateInitial()) {
    on<LoadServerList>((event, emit) async {
      emit(ScreenStateInitial());
      GetIt.I<AuthService>().user = await GetIt.I<AuthService>().getUser();
      try {
        if (GetIt.I<AuthService>().user.authStatus == AuthStatus.authorized) {
          await getServerInfoAuthorizedUser(event, emit);
        } else {
          await getServerInfoUnauthorizedUser(event, emit);
        }
      } catch (e) {
        emit(ScreenStateError('Ошибка загрузки серверов: $e'));
      }
    });

    on<UpdateBalance>((event, emit) {
      this.add(LoadServerList());
    });

    on<Logout>((event, emit) async {
      String email = GetIt.I<AuthService>().user.email;
      String deviceId = GetIt.I<AuthService>().user.deviceId;
      try {
        ServerRepository repository = ServerRepository(
            baseAddress: '${Config.baseUrl}',
            accessToken: GetIt.I<AuthService>().user.accessToken);
        await repository.logout(deviceId, email);
        GetIt.I<AuthService>().logOut();
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        await sharedPreferences.clear();
      } catch (e) {}

      add(LoadServerList());
    });
  }
  Future<void> logOut() async {
    String email = GetIt.I<AuthService>().user.email;
    String deviceId = GetIt.I<AuthService>().user.deviceId;
    try {
      ServerRepository repository = ServerRepository(
          baseAddress: '${Config.baseUrl}',
          accessToken: GetIt.I<AuthService>().user.accessToken);
      await repository.logout(deviceId, email);
      GetIt.I<AuthService>().logOut();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.clear();
    } catch (e) {}

    add(LoadServerList());
  }

  Future<void> getServerInfoUnauthorizedUser(event, emit) async {
    print('getting info for unauthorized user from server repository');
    ServerRepository repository = ServerRepository(
        baseAddress: Config.baseUrl,
        accessToken: GetIt.I<AuthService>().user.accessToken);
    FreeServerHttpModel freeServerHttpModel =
        await repository.getFreeServersInfoCached();
    (freeServerHttpModel.servers ?? [])
        .sort((a, b) => a.load_coef!.compareTo(b.load_coef!));

    RootHttpModel rootModel = RootHttpModel(
        tariffs: freeServerHttpModel.tariffs,
        servers: freeServerHttpModel.servers,
        user_info:
            UserHttpModel(balance: 0, is_blocked: false, current_tarif_id: 1));
    emit(ScreenStateLoaded(rootModel: rootModel));
    try {
      freeServerHttpModel = await repository
          .getFreeServersInfo(GetIt.I<AuthService>().user.email);
      (freeServerHttpModel.servers ?? [])
          .sort((a, b) => a.load_coef!.compareTo(b.load_coef!));
      rootModel = RootHttpModel(
          tariffs: freeServerHttpModel.tariffs,
          servers: freeServerHttpModel.servers,
          user_info: UserHttpModel(
              balance: 0, is_blocked: false, current_tarif_id: 1));
    } catch (e) {
      print(e);
    }

    emit(ScreenStateLoaded(rootModel: rootModel));
  }

  Future<void> getServerInfoAuthorizedUser(event, emit) async {
    ServerRepository repository = ServerRepository(
        baseAddress: '${Config.baseUrl}',
        accessToken: GetIt.I<AuthService>().user.accessToken);
    RootHttpModel rootModel = await repository.getServerInfoCached();
    (rootModel.servers ?? [])
        .sort((a, b) => a.load_coef!.compareTo(b.load_coef!));
    emit(ScreenStateLoaded(rootModel: rootModel));
    try {
      rootModel =
          await repository.getServerInfo(GetIt.I<AuthService>().user.email);
      (rootModel.servers ?? [])
          .sort((a, b) => a.load_coef!.compareTo(b.load_coef!));
    } catch (e) {}

    emit(ScreenStateLoaded(rootModel: rootModel));
  }
}
