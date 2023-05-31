import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class PhotoMenuSettings extends Equatable {
  final bool displayLocalImages, displayCamera, displayMyPhotos;

  const PhotoMenuSettings({
    this.displayLocalImages = true,
    this.displayCamera = true,
    this.displayMyPhotos = true,
  });

  static const String displayPhotoKey = 'image_menu_display_photo_item',
      displayCameraKey = 'image_menu_display_camera_item',
      displayMyPhotosKey = 'image_menu_display_my_photos_item';

  factory PhotoMenuSettings.fromSettingsMap(
          Map<String, GenericSettingData> settings) =>
      PhotoMenuSettings(
        displayLocalImages: settings.getBool(
          displayPhotoKey,
        ),
        displayCamera: settings.getBool(
          displayCameraKey,
        ),
        displayMyPhotos: settings.getBool(
          displayMyPhotosKey,
        ),
      );

  @override
  List<Object?> get props => [
        displayLocalImages,
        displayCamera,
        displayMyPhotos,
      ];
}
