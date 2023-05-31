import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class CategoriesSettings extends Equatable {
  static const calendarActivityTypeShowTypesKey =
          'calendar_activity_type_show_types',
      calendarActivityTypeShowColorKey = 'calendar_activity_type_show_color',
      calendarActivityTypeLeftKey = 'calendar_activity_type_left',
      calendarActivityTypeRightKey = 'calendar_activity_type_right',
      calendarActivityTypeLeftImageKey = 'calendar_activity_type_image_left',
      calendarActivityTypeRightImageKey = 'calendar_activity_type_image_right';
  final bool show, colors;
  final ImageAndName left, right;

  bool get showColors => show && colors;

  const CategoriesSettings({
    this.show = true,
    this.colors = true,
    this.left = ImageAndName.empty,
    this.right = ImageAndName.empty,
  });

  factory CategoriesSettings.fromSettingsMap(
    Map<String, GenericSettingData> settings,
  ) =>
      CategoriesSettings(
        show: settings.getBool(
          calendarActivityTypeShowTypesKey,
        ),
        colors: settings.getBool(
          calendarActivityTypeShowColorKey,
        ),
        left: ImageAndName(
          settings.parse<String>(
            calendarActivityTypeLeftKey,
            '',
          ),
          AbiliaFile.from(
              id: settings.parse<String>(
            calendarActivityTypeLeftImageKey,
            '',
          )),
        ),
        right: ImageAndName(
          settings.parse<String>(
            calendarActivityTypeRightKey,
            '',
          ),
          AbiliaFile.from(
            id: settings.parse<String>(
              calendarActivityTypeRightImageKey,
              '',
            ),
          ),
        ),
      );

  CategoriesSettings copyWith({
    bool? show,
    bool? colors,
    ImageAndName? left,
    ImageAndName? right,
  }) =>
      CategoriesSettings(
        show: show ?? this.show,
        colors: colors ?? this.colors,
        left: left ?? this.left,
        right: right ?? this.right,
      );

  List<GenericSettingData> get memoplannerSettingData => [
        GenericSettingData.fromData(
          data: show,
          identifier: calendarActivityTypeShowTypesKey,
        ),
        GenericSettingData.fromData(
          data: colors,
          identifier: calendarActivityTypeShowColorKey,
        ),
        GenericSettingData.fromData(
          data: left.name,
          identifier: calendarActivityTypeLeftKey,
        ),
        GenericSettingData.fromData(
          data: right.name,
          identifier: calendarActivityTypeRightKey,
        ),
        GenericSettingData.fromData(
          data: left.image.id,
          identifier: calendarActivityTypeLeftImageKey,
        ),
        GenericSettingData.fromData(
          data: right.image.id,
          identifier: calendarActivityTypeRightImageKey,
        ),
      ];

  @override
  List<Object> get props => [
        show,
        colors,
        left,
        right,
      ];
}
