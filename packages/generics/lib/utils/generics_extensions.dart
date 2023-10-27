import 'package:generics/generics.dart';

extension GenericMapExtensions on Map<String, Generic> {
  Map<String, GenericSettingData> filterSettingsData() {
    return (map((key, value) => MapEntry(key, value.data))
          ..removeWhere((key, value) => value is! GenericSettingData))
        .cast<String, GenericSettingData>();
  }
}

extension GenericIterableExtensions on Iterable<Generic> {
  Map<String, Generic> toGenericKeyMap() {
    return {for (var generic in this) generic.data.key: generic};
  }
}

extension GenericExtensions on Generic {
  static String uniqueId(genericTypeString, identifier) =>
      '$genericTypeString-$identifier';
}

extension Parsing on Map<String, GenericSettingData> {
  T parseType<T>(String settingName, String type, T defaultValue) {
    try {
      return this[GenericExtensions.uniqueId(type, settingName)]?.data ??
          defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}
