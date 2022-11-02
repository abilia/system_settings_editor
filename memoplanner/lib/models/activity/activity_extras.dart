part of 'activity.dart';

class Extras extends Equatable {
  static const startTimeExtraAlarmKey = 'startTimeExtraAlarm',
      startTimeExtraAlarmFileIdKey = 'startTimeExtraAlarmFileId',
      endTimeExtraAlarmKey = 'endTimeExtraAlarm',
      endTimeExtraAlarmFileIdKey = 'endTimeExtraAlarmFileId';

  AbiliaFile get startTimeExtraAlarm => AbiliaFile.from(
        id: _extrasMap[startTimeExtraAlarmFileIdKey],
        path: _extrasMap[startTimeExtraAlarmKey],
      );

  AbiliaFile get endTimeExtraAlarm => AbiliaFile.from(
        id: _extrasMap['endTimeExtraAlarmFileId'],
        path: _extrasMap['endTimeExtraAlarm'],
      );

  final Map<String, dynamic> _extrasMap;
  const Extras._(Map<String, dynamic> extrasMap) : _extrasMap = extrasMap;

  static const Extras empty = Extras._({});

  factory Extras.createNew({
    AbiliaFile? startTimeExtraAlarm,
    AbiliaFile? endTimeExtraAlarm,
  }) =>
      Extras._({
        if (startTimeExtraAlarm != null) ...{
          startTimeExtraAlarmKey: startTimeExtraAlarm.path,
          startTimeExtraAlarmFileIdKey: startTimeExtraAlarm.id,
        },
        if (endTimeExtraAlarm != null) ...{
          endTimeExtraAlarmKey: endTimeExtraAlarm.path,
          endTimeExtraAlarmFileIdKey: endTimeExtraAlarm.id,
        }
      });

  Extras copyWith({
    AbiliaFile? startTimeExtraAlarm,
    AbiliaFile? endTimeExtraAlarm,
  }) =>
      Extras._(Map.from(_extrasMap)
        ..addAll(
          {
            if (startTimeExtraAlarm != null) ...{
              startTimeExtraAlarmKey: startTimeExtraAlarm.path,
              startTimeExtraAlarmFileIdKey: startTimeExtraAlarm.id,
            },
            if (endTimeExtraAlarm != null) ...{
              endTimeExtraAlarmKey: endTimeExtraAlarm.path,
              endTimeExtraAlarmFileIdKey: endTimeExtraAlarm.id,
            }
          },
        )
        ..removeWhere((key, value) => value is String && value.isEmpty));

  static Extras fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return Extras.empty;
    try {
      return Extras._(
        jsonDecode(jsonString),
      );
    } on FormatException catch (_) {
      return Extras.empty;
    }
  }

  String toJsonString() => json.encode(_extrasMap);

  @override
  List<Object?> get props => [_extrasMap];

  @override
  bool get stringify => true;
}
