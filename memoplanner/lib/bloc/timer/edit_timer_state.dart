part of 'edit_timer_cubit.dart';

class TimerData extends Equatable {
  final Duration duration;
  final AbiliaFile image;
  final String name;
  final bool autoSetNameToDuration;

  const TimerData({
    this.duration = Duration.zero,
    this.name = '',
    this.autoSetNameToDuration = true,
    this.image = AbiliaFile.empty,
  });

  TimerData copyWith({
    Duration? duration,
    String? name,
    bool? autoSetNameToDuration,
    AbiliaFile? image,
    int? step,
    DateTime? startTime,
  }) {
    return TimerData(
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

class EditTimerState extends Equatable {
  late final TimerData originalTimerData;
  final TimerData timerData;

  bool get unchanged => timerData == originalTimerData;

  Duration get duration => timerData.duration;

  String get name => timerData.name;

  bool get autoSetNameToDuration => timerData.autoSetNameToDuration;

  AbiliaFile get image => timerData.image;

  EditTimerState({
    required this.timerData,
    TimerData? originalTimerData,
  }) {
    this.originalTimerData = originalTimerData ?? timerData;
  }

  factory EditTimerState.initial() {
    return EditTimerState(
      timerData: const TimerData(),
    );
  }

  factory EditTimerState.withBasicTimer(BasicTimerDataItem basicTimer) {
    return EditTimerState(
      timerData: TimerData(
        duration: basicTimer.duration.milliseconds(),
        name: basicTimer.basicTimerTitle,
        autoSetNameToDuration: basicTimer.duration == 0,
        image: basicTimer.hasImage()
            ? AbiliaFile.from(id: basicTimer.fileId, path: basicTimer.icon)
            : AbiliaFile.empty,
      ),
    );
  }

  EditTimerState copyWith(TimerData timerData) => EditTimerState(
        originalTimerData: originalTimerData,
        timerData: timerData,
      );

  @override
  List<Object?> get props => [timerData];
}

class SavedTimerState extends EditTimerState {
  final AbiliaTimer savedTimer;

  SavedTimerState(EditTimerState state, this.savedTimer)
      : super(
          timerData: TimerData(
            duration: state.duration,
            name: state.name,
            autoSetNameToDuration: state.autoSetNameToDuration,
            image: state.image,
          ),
        );

  @override
  List<Object?> get props => [savedTimer];
}
