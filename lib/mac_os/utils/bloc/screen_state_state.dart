part of 'screen_state_bloc.dart';

@immutable
sealed class ScreenStateState {
  final RootHttpModel? rootModel;

  const ScreenStateState({this.rootModel});
}

class ScreenStateInitial extends ScreenStateState {}

class ScreenStateLoaded extends ScreenStateState {
  const ScreenStateLoaded({required RootHttpModel rootModel})
      : super(rootModel: rootModel);
}

class ScreenStateError extends ScreenStateState {
  final String message;
  const ScreenStateError(this.message);
}
