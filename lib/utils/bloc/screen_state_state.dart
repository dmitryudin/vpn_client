part of 'screen_state_bloc.dart';

@immutable
sealed class ScreenStateState {
  final List<ServerInfoModel> servers;
  final int balance;

  const ScreenStateState({this.servers = const [], this.balance = 0});
}

class ScreenStateInitial extends ScreenStateState {}

class ScreenStateLoaded extends ScreenStateState {
  const ScreenStateLoaded(
      {required List<ServerInfoModel> servers, required int balance})
      : super(servers: servers, balance: balance);
}

class ScreenStateError extends ScreenStateState {
  final String message;
  const ScreenStateError(this.message);
}
