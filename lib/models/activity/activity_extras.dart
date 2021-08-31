import 'dart:convert';

import 'package:equatable/equatable.dart';

class Extras extends Equatable {
  final String startTimeExtraAlarm;
  final String startTimeExtraAlarmFileId;
  final String endTimeExtraAlarm;
  final String endTimeExtraAlarmFileId;

  const Extras(
      {this.startTimeExtraAlarm = '',
        this.startTimeExtraAlarmFileId = '',
        this.endTimeExtraAlarm = '',
        this.endTimeExtraAlarmFileId = ''});

  Extras copyWith({
    String? startTimeExtraAlarm,
    String? startTimeExtraAlarmFileId,
    String? endTimeExtraAlarm,
    String? endTimeExtraAlarmFileId,
  }) =>
      Extras(
        startTimeExtraAlarm: startTimeExtraAlarm ?? this.startTimeExtraAlarm,
        startTimeExtraAlarmFileId:
        startTimeExtraAlarmFileId ?? this.startTimeExtraAlarmFileId,
        endTimeExtraAlarm: endTimeExtraAlarm ?? this.startTimeExtraAlarm,
        endTimeExtraAlarmFileId:
        endTimeExtraAlarmFileId ?? this.endTimeExtraAlarmFileId,
      );

  static Extras fromBase64(String? base64) {
    if (base64 == null || base64.isEmpty) return empty;
    final jsonString = utf8.decode(base64Decode(base64));
    return fromJsonString(jsonString);
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
      startTimeExtraAlarm: json['startTimeExtraAlarm'] ?? '',
      startTimeExtraAlarmFileId: json['startTimeExtraAlarmFileId'] ?? '',
      endTimeExtraAlarm: json['endTimeExtraAlarm'] ?? '',
      endTimeExtraAlarmFileId: json['endTimeExtraAlarmFileId'] ?? '',
    );
  }

  static const Extras empty = Extras();

  Map<String, dynamic> toJson() => {
    'startTimeExtraAlarm': startTimeExtraAlarm,
    'startTimeExtraAlarmFileId': startTimeExtraAlarmFileId,
    'endTimeExtraAlarm': endTimeExtraAlarm,
    'endTimeExtraAlarmFileId': endTimeExtraAlarmFileId,
  }..removeWhere((key, value) => value == '' || value == null);

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
