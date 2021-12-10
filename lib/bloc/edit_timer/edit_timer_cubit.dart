import 'package:flutter_bloc/flutter_bloc.dart';

class EditTimerCubit extends Cubit<EditTimerState> {
  EditTimerCubit(int hours, int minutes)
      : super(EditTimerState(minutes, hours));

  void updateDuration({int? hours, int? minutes}) {
    emit(state.copyWith(hours, minutes));
  }
}

class EditTimerState {
  final int hours;
  final int minutes;
  late final Duration duration;

  EditTimerState(this.hours, this.minutes) {
    duration = Duration(hours: hours, minutes: minutes);
  }

  EditTimerState copyWith(int? hours, int? minutes) {
    return EditTimerState(hours ?? this.hours, minutes ?? this.minutes);
  }
}
