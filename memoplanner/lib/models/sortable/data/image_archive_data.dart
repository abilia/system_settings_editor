import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:memoplanner/i18n/all.dart';
import 'package:memoplanner/models/all.dart';

class ImageArchiveData extends SortableData {
  static const photoCalendarTag = 'photoCalendar';
  final String name, fileId, icon, file;
  final bool upload, myPhotos;
  final UnmodifiableSetView<String> tags;

  const ImageArchiveData({
    this.name = '',
    this.file = '',
    this.fileId = '',
    this.icon = '',
    this.upload = false,
    this.myPhotos = false,
    this.tags = const UnmodifiableSetView.empty(),
  }) : super();

  @override
  String toRaw() => json.encode({
        if (name.isNotEmpty) 'name': name,
        if (fileId.isNotEmpty) 'fileId': fileId,
        if (icon.isNotEmpty) 'icon': icon,
        if (file.isNotEmpty) 'file': file,
        if (upload) 'upload': upload,
        if (myPhotos) 'myPhotos': myPhotos,
        if (tags.isNotEmpty) 'tags': tags.toList(),
      });

  @override
  List<Object?> get props => [name, fileId, icon, file, tags];

  factory ImageArchiveData.fromJson(String data) {
    final sortableData = json.decode(data);
    return ImageArchiveData(
      name: sortableData['name'] ?? '',
      fileId: sortableData['fileId'] ?? '',
      icon: sortableData['icon'] ?? '',
      file: sortableData['file'] ?? '',
      upload: sortableData['upload'] ?? false,
      myPhotos: sortableData['myPhotos'] ?? false,
      tags: sortableData['tags'] is List<dynamic>
          ? UnmodifiableSetView((Set<String>.from(sortableData['tags'])))
          : const UnmodifiableSetView.empty(),
    );
  }

  @override
  String title(Translated t) => myPhotos
      ? t.myPhotos
      : upload
          ? t.mobilePictures
          : name;

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;

  bool isInPhotoCalendar() => tags.contains(photoCalendarTag);

  ImageArchiveData copyWith({
    String? name,
    Iterable<String>? tags,
  }) =>
      ImageArchiveData(
        name: name ?? this.name,
        tags: tags != null ? UnmodifiableSetView(tags.toSet()) : this.tags,
        fileId: fileId,
        icon: icon,
        file: file,
        upload: upload,
        myPhotos: myPhotos,
      );
}
