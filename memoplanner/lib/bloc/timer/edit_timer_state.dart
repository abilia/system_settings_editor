part of 'edit_timer_cubit.dart';

class EditTimerState extends Equatable {
  final Duration duration;
  final AbiliaFile image;
  final String name;
  final bool autoSetNameToDuration;

  const EditTimerState({
    this.duration = Duration.zero,
    this.name = '',
    this.autoSetNameToDuration = true,
    this.image = AbiliaFile.empty,
  });

  factory EditTimerState.initial() {
    return const EditTimerState();
  }

  factory EditTimerState.withBasicTimer(BasicTimerDataItem basicTimer) {
    return EditTimerState(
      duration: basicTimer.duration.milliseconds(),
      name: basicTimer.basicTimerTitle,
      autoSetNameToDuration: basicTimer.duration == 0,
      image: basicTimer.hasImage()
          ? AbiliaFile.from(id: basicTimer.fileId, path: basicTimer.icon)
          : AbiliaFile.empty,
    );
  }

  EditTimerState copyWith({
    Duration? duration,
    String? name,
    bool? autoSetNameToDuration,
    AbiliaFile? image,
    int? step,
    DateTime? startTime,
  }) {
    return EditTimerState(
      duration: duration ?? this.duration,
      name: name ?? this.name,
      autoSetNameToDuration:
          autoSetNameToDuration ?? this.autoSetNameToDuration,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [duration, name, autoSetNameToDuration, image];
}

class SavedTimerState extends EditTimerState {
  final AbiliaTimer savedTimer;
  SavedTimerState(EditTimerState state, this.savedTimer)
      : super(
          duration: state.duration,
          name: state.name,
          autoSetNameToDuration: state.autoSetNameToDuration,
          image: state.image,
        );

  @override
  List<Object?> get props => [savedTimer];
}
