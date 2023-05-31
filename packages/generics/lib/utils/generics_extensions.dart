import 'package:generics/generics.dart';

extension GenericMapExtensions on Map<String, Generic> {
  Map<String, GenericSettingData> filterMemoplannerSettingsData() {
    return (map((key, value) => MapEntry(key, value.data))
          ..removeWhere((key, value) => value is! GenericSettingData))
        .cast<String, GenericSettingData>();
  }
}

extension GenericExtensions on Iterable<Generic> {
  Map<String, Generic> toGenericKeyMap() {
    return {for (var generic in this) generic.data.key: generic};
  }
}
