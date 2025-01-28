import 'package:auth_feature/data/auth_data.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_engine/from_server/server_info_model.dart';

part 'screen_state_event.dart';
part 'screen_state_state.dart';

class ScreenStateBloc extends Bloc<ScreenStateEvent, ScreenStateState> {
  ScreenStateBloc() : super(ScreenStateInitial()) {
    on<LoadServerList>((event, emit) async {
      try {
        if (GetIt.I<AuthService>().user.status);
        ServerRepository repository = ServerRepository(baseAddress: '', accessToken: );
        // Получаем email из SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('user_email') ?? '';

        final serverInfo = await repository.getServerInfo(email);
        emit(ScreenStateLoaded(servers: [serverInfo], balance: state.balance));
      } catch (e) {
        emit(ScreenStateError('Ошибка загрузки серверов: $e'));
      }
    });

    on<UpdateBalance>((event, emit) {
      if (state is ScreenStateLoaded) {
        emit(ScreenStateLoaded(servers: state.servers, balance: event.balance));
      }
    });
  }
}
