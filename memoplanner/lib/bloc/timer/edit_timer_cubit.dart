import 'package:equatable/equatable.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'edit_timer_state.dart';

class EditTimerCubit extends Cubit<EditTimerState> {
  final TimerCubit timerCubit;
  final Translated translate;
  final Ticker ticker;

  EditTimerCubit({
    required this.timerCubit,
    required this.translate,
    required this.ticker,
    BasicTimerDataItem? basicTimer,
  }) : super(basicTimer == null
            ? EditTimerState.initial()
            : EditTimerState.withBasicTimer(basicTimer));

  void start() {
    final timer = save();
    timerCubit.addTimer(timer);
  }

  AbiliaTimer save() {
    final timer = AbiliaTimer.createNew(
      title: state.name,
      fileId: state.image.id,
      duration: state.duration,
      startTime: ticker.time,
    );
    emit(SavedTimerState(state, timer));
    return timer;
  }

  void updateDuration(Duration duration) => emit(
        state.copyWith(
          duration: duration,
          name: state.autoSetNameToDuration
              ? duration.toDurationString(translate, shortMin: false)
              : null,
        ),
      );

  void updateName(String text) => emit(
        state.copyWith(
          name: text.trim(),
          autoSetNameToDuration: false,
        ),
      );

  void loadBasicTimer(BasicTimerDataItem basicTimer) =>
      emit(EditTimerState.withBasicTimer(basicTimer));

  void updateImage(AbiliaFile file) => emit(state.copyWith(image: file));
}
