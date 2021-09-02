part of 'activity.dart';

class Extras extends Equatable {
  static const startTimeExtraAlarmKey = 'startTimeExtraAlarm',
      startTimeExtraAlarmFileIdKey = 'startTimeExtraAlarmFileId',
      endTimeExtraAlarmKey = 'endTimeExtraAlarm',
      endTimeExtraAlarmFileIdKey = 'endTimeExtraAlarmFileId';

  String get startTimeExtraAlarm => _extrasMap[startTimeExtraAlarmKey] ?? '';
  String get startTimeExtraAlarmFileId =>
      _extrasMap[startTimeExtraAlarmFileIdKey] ?? '';
  String get endTimeExtraAlarm => _extrasMap['endTimeExtraAlarm'] ?? '';
  String get endTimeExtraAlarmFileId =>
      _extrasMap['endTimeExtraAlarmFileId'] ?? '';

  final Map<String, dynamic> _extrasMap;
  const Extras._(Map<String, dynamic> extrasMap) : _extrasMap = extrasMap;

  static const Extras empty = Extras._({});

  factory Extras.createNew({
    String? startTimeExtraAlarm,
    String? startTimeExtraAlarmFileId,
    String? endTimeExtraAlarm,
    String? endTimeExtraAlarmFileId,
  }) =>
      Extras._({
        startTimeExtraAlarmKey: startTimeExtraAlarm,
        startTimeExtraAlarmFileIdKey: startTimeExtraAlarmFileId,
        endTimeExtraAlarmKey: endTimeExtraAlarm,
        endTimeExtraAlarmFileIdKey: endTimeExtraAlarmFileId
      });

  Extras copyWith({
    String? startTimeExtraAlarm,
    String? startTimeExtraAlarmFileId,
    String? endTimeExtraAlarm,
    String? endTimeExtraAlarmFileId,
  }) =>
      Extras._(Map.from(_extrasMap)
        ..addAll(
          {
            if (startTimeExtraAlarm != null)
              startTimeExtraAlarmKey: startTimeExtraAlarm,
            if (startTimeExtraAlarmFileId != null)
              startTimeExtraAlarmFileIdKey: startTimeExtraAlarmFileId,
            if (endTimeExtraAlarm != null)
              endTimeExtraAlarmKey: endTimeExtraAlarm,
            if (endTimeExtraAlarmFileId != null)
              endTimeExtraAlarmFileIdKey: endTimeExtraAlarmFileId,
          },
        )
        ..removeWhere((key, value) => value is String && value.isEmpty));

  static Extras fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return Extras.empty;
    return Extras._(jsonDecode(jsonString));
  }

  static Extras fromBase64(String? base64) {
    if (base64 == null || base64.isEmpty) return Extras.empty;
    try {
      return fromJsonString(utf8.decode(base64Decode(base64)));
    } on FormatException catch (_) {
      return Extras.empty;
    }
  }

  String toJsonString() => json.encode(_extrasMap);

  String toBase64() => base64Encode(utf8.encode(toJsonString()));

  @override
  List<Object?> get props => [_extrasMap];

  @override
  bool get stringify => true;
}
