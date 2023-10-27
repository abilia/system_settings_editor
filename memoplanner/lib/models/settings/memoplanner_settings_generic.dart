import 'package:memoplanner/models/all.dart';

class MemoplannerSettingData<T> extends GenericSettingData<T> {
  static const String genericType = 'memoPlannerSettings';
  MemoplannerSettingData({
    required super.data,
    required super.identifier,
  }) : super(type: genericType);
}
