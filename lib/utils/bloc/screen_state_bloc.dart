import 'package:auth_feature/auth_feature.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_engine/from_server/api_server/models/root_model.dart';
import 'package:vpn_engine/from_server/api_server/models/server_http_model.dart';
import 'package:vpn_engine/from_server/api_server/models/tariff_http_model.dart';
import 'package:vpn_engine/from_server/server_info_model.dart';

part 'screen_state_event.dart';
part 'screen_state_state.dart';

class ScreenStateBloc extends Bloc<ScreenStateEvent, ScreenStateState> {
  ScreenStateBloc() : super(ScreenStateInitial()) {
    on<LoadServerList>((event, emit) async {
      emit(ScreenStateInitial());
      GetIt.I<AuthService>().user = await GetIt.I<AuthService>().getUser();
      print(GetIt.I<AuthService>().user.accessToken);
      try {
        if (GetIt.I<AuthService>().user.authStatus == AuthStatus.authorized) {
          ServerRepository repository = ServerRepository(
              baseAddress: 'http://109.196.101.63:8000',
              accessToken: GetIt.I<AuthService>().user.accessToken);
          // Получаем email из SharedPreferences
          final prefs = await SharedPreferences.getInstance();

          final rootModel =
              await repository.getServerInfo(GetIt.I<AuthService>().user.email);
          for (TariffHttpModel tariffModel in rootModel.tariffs) {
            print(tariffModel.toJson());
          }

          emit(ScreenStateLoaded(rootModel: rootModel));
        }
      } catch (e) {
        emit(ScreenStateError('Ошибка загрузки серверов: $e'));
      }
    });

    on<UpdateBalance>((event, emit) {
      this.add(LoadServerList());
    });
  }
}
