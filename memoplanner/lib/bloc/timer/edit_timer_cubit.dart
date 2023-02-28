import 'package:equatable/equatable.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

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
            : EditTimerState.fromTemplate(basicTimer));

  void start() {
    final timer = save();
    timerCubit.addTimer(
      timer,
      state.metaData,
    );
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

  void updateDuration(Duration duration, TimerSetType timerSetType) => emit(
        state.copyWith(
          metaData: state.metaData.copyWith(timerSetType: timerSetType),
          duration: duration,
          name: state.autoSetNameToDuration
              ? duration.toDurationString(translate, shortMin: false)
              : null,
        ),
      );

  void updateName(String text) => emit(
        state.copyWith(
          metaData: state.metaData.copyWith(titleChanged: true),
          name: text.trim(),
          autoSetNameToDuration: false,
        ),
      );

  void loadTimerTemplate(BasicTimerDataItem basicTimer) =>
      emit(EditTimerState.fromTemplate(basicTimer));

  void updateImage(AbiliaFile file) => emit(state.copyWith(image: file));
}
