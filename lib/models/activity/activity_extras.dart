import 'dart:convert';

import 'package:equatable/equatable.dart';

class Extras extends Equatable {
  final Map<String, dynamic> extrasMap;
  final String startTimeExtraAlarm;
  final String startTimeExtraAlarmFileId;
  final String endTimeExtraAlarm;
  final String endTimeExtraAlarmFileId;

  const Extras({
    this.extrasMap = const {
      'startTimeExtraAlarm': '',
      'startTimeExtraAlarmFileId': '',
      'endTimeExtraAlarm': '',
      'endTimeExtraAlarmFileId': '',
    },
    this.startTimeExtraAlarm = '',
    this.startTimeExtraAlarmFileId = '',
    this.endTimeExtraAlarm = '',
    this.endTimeExtraAlarmFileId = '',
  });

  Extras copyWith({
    Map<String, dynamic>? extrasMap,
    String? startTimeExtraAlarm,
    String? startTimeExtraAlarmFileId,
    String? endTimeExtraAlarm,
    String? endTimeExtraAlarmFileId,
  }) =>
      Extras(
        extrasMap: extrasMap ?? this.extrasMap,
        startTimeExtraAlarm: startTimeExtraAlarm ?? this.startTimeExtraAlarm,
        startTimeExtraAlarmFileId:
            startTimeExtraAlarmFileId ?? this.startTimeExtraAlarmFileId,
        endTimeExtraAlarm: endTimeExtraAlarm ?? this.endTimeExtraAlarm,
        endTimeExtraAlarmFileId:
            endTimeExtraAlarmFileId ?? this.endTimeExtraAlarmFileId,
      );

  static Extras fromBase64(String? base64) {
    if (base64 == null || base64.isEmpty) return empty;
    try {
      final jsonString = utf8.decode(base64Decode(base64));
      return fromJsonString(jsonString);
    } on FormatException catch (_, ex) {
      return Extras.empty;
    }
  }

  static Extras fromJsonString(String jsonString) {
    return jsonString.isNotEmpty
        ? jsonString.startsWith('{')
            ? Extras.fromJson(jsonDecode(jsonString))
            : Extras.fromBase64(jsonString)
        : empty;
  }

  factory Extras.fromJson(Map<String, dynamic> json) {
    return Extras(
      extrasMap: json,
      startTimeExtraAlarm: json['startTimeExtraAlarm'] ?? '',
      startTimeExtraAlarmFileId: json['startTimeExtraAlarmFileId'] ?? '',
      endTimeExtraAlarm: json['endTimeExtraAlarm'] ?? '',
      endTimeExtraAlarmFileId: json['endTimeExtraAlarmFileId'] ?? '',
    );
  }

  factory Extras.fromUnknown(Object object) {
    if (object is String) {
      return Extras.fromJsonString(object);
    } else if (object is Map<String, dynamic>) {
      return Extras.fromJson(object);
    } else {
      return Extras.empty;
    }
  }

  static const Extras empty = Extras();

  Map<String, dynamic> toJson() {
    var newMap = <String, dynamic>{};
    newMap.addAll(extrasMap);
    newMap['startTimeExtraAlarm'] = startTimeExtraAlarm;
    newMap['startTimeExtraAlarmFileId'] = startTimeExtraAlarmFileId;
    newMap['endTimeExtraAlarm'] = endTimeExtraAlarm;
    newMap['endTimeExtraAlarmFileId'] = endTimeExtraAlarmFileId;
    return newMap..removeWhere((key, value) => value == '' || value == null);
  }

  String toJsonString() {
    return json.encode(
      toJson(),
    );
  }

  String? toBase64() => base64Encode(
        utf8.encode(toJsonString()),
      );

  bool get hasStartTimeExtraAlarm =>
      startTimeExtraAlarm.isNotEmpty || startTimeExtraAlarmFileId.isNotEmpty;

  @override
  List<Object?> get props => [
        startTimeExtraAlarm,
        startTimeExtraAlarmFileId,
        endTimeExtraAlarm,
        endTimeExtraAlarmFileId
      ];

  @override
  bool get stringify => true;
}
