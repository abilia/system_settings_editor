import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class DefaultsAddActivitySettings extends Equatable {
  static const defaultCheckableKey = 'add_activity_default_checkable',
      defaultRemoveAtEndOfDayKey = 'add_activity_default_remove_end_of_day',
      defaultAvailableForTypeKey = 'add_activity_default_available_for_type',
      defaultAlarmTypeKey = 'add_activity_default_alarm_type';

  final Alarm alarm;
  final AvailableForType availableForType;
  final bool checkable, removeAtEndOfDay;

  const DefaultsAddActivitySettings({
    this.alarm = const Alarm(type: AlarmType.soundAndVibration),
    this.availableForType = AvailableForType.allSupportPersons,
    this.checkable = false,
    this.removeAtEndOfDay = false,
  });

  DefaultsAddActivitySettings copyWith({
    Alarm? alarm,
    AvailableForType? availableForType,
    bool? checkable,
    bool? removeAtEndOfDay,
    bool? noEndDate,
  }) =>
      DefaultsAddActivitySettings(
        availableForType: availableForType ?? this.availableForType,
        alarm: alarm ?? this.alarm,
        checkable: checkable ?? this.checkable,
        removeAtEndOfDay: removeAtEndOfDay ?? this.removeAtEndOfDay,
      );

  factory DefaultsAddActivitySettings.fromSettingsMap(
          Map<String, GenericSettingData> settings) =>
      DefaultsAddActivitySettings(
        alarm: Alarm.fromInt(
          settings.parse(
            defaultAlarmTypeKey,
            alarmSoundAndVibration,
          ),
        ),
        availableForType: AvailableForType.values[settings.parse(
          defaultAvailableForTypeKey,
          AvailableForType.allSupportPersons.index,
        )],
        checkable: settings.getBool(
          defaultCheckableKey,
          defaultValue: false,
        ),
        removeAtEndOfDay: settings.getBool(
          defaultRemoveAtEndOfDayKey,
          defaultValue: false,
        ),
      );

  List<GenericSettingData> get memoplannerSettingData => [
        MemoplannerSettingData(
          data: alarm.intValue,
          identifier: defaultAlarmTypeKey,
        ),
        MemoplannerSettingData(
          data: availableForType.index,
          identifier: defaultAvailableForTypeKey,
        ),
        MemoplannerSettingData(
          data: checkable,
          identifier: defaultCheckableKey,
        ),
        MemoplannerSettingData(
          data: removeAtEndOfDay,
          identifier: defaultRemoveAtEndOfDayKey,
        ),
      ];

  @override
  List<Object?> get props => [
        checkable,
        removeAtEndOfDay,
        availableForType,
        alarm,
      ];
}
