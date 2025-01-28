part of 'screen_state_bloc.dart';

@immutable
sealed class ScreenStateEvent {}

class LoadServerList extends ScreenStateEvent {}

class UpdateBalance extends ScreenStateEvent {
  final int balance;
  UpdateBalance(this.balance);
}
