import 'package:seagull/models/all.dart';

extension GenericMapExtensions on Map<String, Generic> {
  Map<String, MemoplannerSettingData> filterMemoplannerSettingsData() {
    return (map((key, value) => MapEntry(key, value.data))
          ..removeWhere((key, value) => value is! MemoplannerSettingData))
        .cast<String, MemoplannerSettingData>();
  }
}

extension GenericExtensions on Iterable<Generic> {
  Map<String, Generic> toGenericKeyMap() {
    return {for (var generic in this) generic.data.key: generic};
  }
}
