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

class EditTimerMetaData {
  final bool titleChanged, fromTemplate;
  final TimerSetType timerSetType;

  EditTimerMetaData({
    required this.fromTemplate,
    this.titleChanged = false,
    this.timerSetType = TimerSetType.unchanged,
  });

  EditTimerMetaData copyWith({
    bool? titleChanged,
    TimerSetType? timerSetType,
  }) {
    return EditTimerMetaData(
      titleChanged: titleChanged ?? this.titleChanged,
      timerSetType: timerSetType ?? this.timerSetType,
      fromTemplate: fromTemplate,
    );
  }
}

enum TimerSetType { wheel, inputField, unchanged }

class EditTimerState extends Equatable {
  late final TimerData _originalTimerData;
  final TimerData timerData;
  final EditTimerMetaData metaData;

  bool get unchanged => timerData == _originalTimerData;

  Duration get duration => timerData.duration;

  String get durationText {
    final text = timerData.duration.toString();
    final index = text.lastIndexOf(':');
    return text.substring(0, index).padLeft(5, '0');
  }

  String get name => timerData.name;

  bool get autoSetNameToDuration => timerData.autoSetNameToDuration;

  AbiliaFile get image => timerData.image;

  EditTimerState._({
    required this.timerData,
    required this.metaData,
    TimerData? originalTimerData,
  }) {
    _originalTimerData = originalTimerData ?? timerData;
  }

  factory EditTimerState.initial() => EditTimerState._(
        timerData: const TimerData(),
        metaData: EditTimerMetaData(fromTemplate: false),
      );

  factory EditTimerState.fromTemplate(BasicTimerDataItem timerTemplate) {
    return EditTimerState._(
      metaData: EditTimerMetaData(fromTemplate: true),
      timerData: TimerData(
        duration: timerTemplate.duration.milliseconds(),
        name: timerTemplate.basicTimerTitle,
        autoSetNameToDuration: timerTemplate.duration == 0,
        image: timerTemplate.hasImage()
            ? AbiliaFile.from(
                id: timerTemplate.fileId, path: timerTemplate.icon)
            : AbiliaFile.empty,
      ),
    );
  }

  EditTimerState copyWith({
    Duration? duration,
    String? name,
    bool? autoSetNameToDuration,
    AbiliaFile? image,
    EditTimerMetaData? metaData,
  }) =>
      EditTimerState._(
        metaData: metaData ?? this.metaData,
        originalTimerData: _originalTimerData,
        timerData: timerData.copyWith(
          duration: duration,
          name: name,
          autoSetNameToDuration: autoSetNameToDuration,
          image: image,
        ),
      );

  @override
  List<Object?> get props => [_originalTimerData, timerData];
}

class SavedTimerState extends EditTimerState {
  final AbiliaTimer savedTimer;
  SavedTimerState(EditTimerState state, this.savedTimer)
      : super._(
          metaData: state.metaData,
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
