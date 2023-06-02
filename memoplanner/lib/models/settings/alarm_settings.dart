import 'package:equatable/equatable.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/models/all.dart';

class AlarmSettings extends Equatable {
  Sound get nonCheckableSound => nonCheckableActivity.toSound();
  Sound get checkableSound => checkableActivity.toSound();
  Sound get reminderSound => reminder.toSound();
  Sound get timerSound => timer.toSound();
  AlarmDuration get alarmDuration => durationMs.toAlarmDuration();
  bool get showOngoingActivityInFullScreen =>
      Config.isMP && _showOngoingActivityInFullScreen;

  static const nonCheckableActivityAlarmKey = 'activity_alarm_without_confirm',
      checkableActivityAlarmKey = 'activity_alarm_with_confirm',
      reminderAlarmKey = 'activity_reminder_alarm',
      timerAlarmKey = 'activity_timer_alarm',
      alarmDurationKey = 'alarm_duration',
      alarmsDisabledUntilKey = 'alarms_disabled_until',
      showAlarmOnOffSwitchKey = 'show_alarms_button',
      showOngoingActivityInFullScreenKey =
          'setting_show_activity_in_full_screen';

  static const keys = {
    nonCheckableActivityAlarmKey,
    checkableActivityAlarmKey,
    reminderAlarmKey,
    timerAlarmKey,
    alarmDurationKey,
    alarmsDisabledUntilKey,
    showAlarmOnOffSwitchKey,
    showOngoingActivityInFullScreenKey,
  };

  final int durationMs, disabledUntilEpoch;
  final bool showAlarmOnOffSwitch, _showOngoingActivityInFullScreen;

  final String checkableActivity, nonCheckableActivity, reminder, timer;

  Sound get nonCheckableAlarm => nonCheckableActivity.toSound();

  Sound get checkableAlarm => checkableActivity.toSound();

  Duration get duration => Duration(milliseconds: durationMs);

  DateTime get disabledUntilDate =>
      DateTime.fromMillisecondsSinceEpoch(disabledUntilEpoch);

  const AlarmSettings({
    this.durationMs = 30000,
    this.checkableActivity = SoundExtension.defaultName,
    this.nonCheckableActivity = SoundExtension.defaultName,
    this.reminder = SoundExtension.defaultName,
    this.timer = SoundExtension.defaultName,
    this.disabledUntilEpoch = 0,
    this.showAlarmOnOffSwitch = false,
    bool showOngoingActivityInFullScreen = false,
  }) : _showOngoingActivityInFullScreen = showOngoingActivityInFullScreen;

  AlarmSettings copyWith({
    Sound? nonCheckableSound,
    Sound? checkableSound,
    Sound? reminderSound,
    Sound? timerSound,
    AlarmDuration? alarmDuration,
    bool? showAlarmOnOffSwitch,
    bool? showOngoingActivityInFullScreen,
  }) =>
      AlarmSettings(
        durationMs: alarmDuration?.milliseconds() ?? durationMs,
        nonCheckableActivity: nonCheckableSound?.name ?? nonCheckableActivity,
        checkableActivity: checkableSound?.name ?? checkableActivity,
        reminder: reminderSound?.name ?? reminder,
        timer: timerSound?.name ?? timer,
        showAlarmOnOffSwitch: showAlarmOnOffSwitch ?? this.showAlarmOnOffSwitch,
        showOngoingActivityInFullScreen:
            showOngoingActivityInFullScreen ?? _showOngoingActivityInFullScreen,
      );

  factory AlarmSettings.fromSettingsMap(
          Map<String, GenericSettingData> settings) =>
      AlarmSettings(
        durationMs: settings.parse(
          alarmDurationKey,
          30000,
        ),
        checkableActivity: settings.parse(
          checkableActivityAlarmKey,
          Sound.Default.name,
        ),
        nonCheckableActivity: settings.parse(
          nonCheckableActivityAlarmKey,
          Sound.Default.name,
        ),
        reminder: settings.parse(
          reminderAlarmKey,
          Sound.Default.name,
        ),
        timer: settings.parse(
          timerAlarmKey,
          Sound.Default.name,
        ),
        disabledUntilEpoch: settings.parse(
          alarmsDisabledUntilKey,
          0,
        ),
        showAlarmOnOffSwitch: settings.getBool(
          showAlarmOnOffSwitchKey,
          defaultValue: false,
        ),
        showOngoingActivityInFullScreen: settings.getBool(
          showOngoingActivityInFullScreenKey,
          defaultValue: false,
        ),
      );

  factory AlarmSettings.fromMap(Map<String, dynamic> data) {
    return AlarmSettings(
      durationMs: data[alarmDurationKey],
      checkableActivity: data[checkableActivityAlarmKey],
      nonCheckableActivity: data[nonCheckableActivityAlarmKey],
      reminder: data[reminderAlarmKey],
      timer: data[timerAlarmKey],
      disabledUntilEpoch: data[alarmsDisabledUntilKey],
      showAlarmOnOffSwitch: data[showAlarmOnOffSwitchKey],
      showOngoingActivityInFullScreen: data[showOngoingActivityInFullScreenKey],
    );
  }

  Map<String, dynamic> toMap() => {
        alarmDurationKey: durationMs,
        checkableActivityAlarmKey: checkableActivity,
        nonCheckableActivityAlarmKey: nonCheckableActivity,
        reminderAlarmKey: reminder,
        timerAlarmKey: timer,
        alarmsDisabledUntilKey: disabledUntilEpoch,
        showAlarmOnOffSwitchKey: showAlarmOnOffSwitch,
        showOngoingActivityInFullScreenKey: showOngoingActivityInFullScreen,
      };

  List<GenericSettingData> get memoplannerSettingData => [
        GenericSettingData.fromData(
          data: nonCheckableSound.name,
          identifier: AlarmSettings.nonCheckableActivityAlarmKey,
        ),
        GenericSettingData.fromData(
          data: checkableSound.name,
          identifier: AlarmSettings.checkableActivityAlarmKey,
        ),
        GenericSettingData.fromData(
          data: reminderSound.name,
          identifier: AlarmSettings.reminderAlarmKey,
        ),
        GenericSettingData.fromData(
          data: timerSound.name,
          identifier: AlarmSettings.timerAlarmKey,
        ),
        GenericSettingData.fromData(
          data: alarmDuration.milliseconds(),
          identifier: AlarmSettings.alarmDurationKey,
        ),
        GenericSettingData.fromData(
          data: showAlarmOnOffSwitch,
          identifier: AlarmSettings.showAlarmOnOffSwitchKey,
        ),
        GenericSettingData.fromData(
          data: _showOngoingActivityInFullScreen,
          identifier: AlarmSettings.showOngoingActivityInFullScreenKey,
        )
      ];

  @override
  List<Object?> get props => [
        duration,
        checkableActivity,
        nonCheckableActivity,
        reminder,
        timer,
        disabledUntilEpoch,
        showAlarmOnOffSwitch,
        _showOngoingActivityInFullScreen,
      ];

  @override
  bool get stringify => true;
}
