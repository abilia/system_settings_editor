import 'dart:io';

import 'package:seagull/models/image_thumb.dart';

class FileStorage {
  final String _storageDirectory;

  static const folder = 'seagull';

  FileStorage(this._storageDirectory);

  Future<void> storeFile(List<int> fileBytes, String fileName) async {
    final file = await File('${_storageDirectory}/$folder/$fileName')
        .create(recursive: true);
    await file.writeAsBytes(fileBytes);
  }

  Future<void> storeImageThumb(
      List<int> fileBytes, ImageThumb imageThumb) async {
    return storeFile(fileBytes, imageThumb.thumbId);
  }

  File getFile(String id) {
    final path = '$_storageDirectory/$folder/$id';
    return File(path);
  }

  File getImageThumb(ImageThumb imageThumb) {
    return getFile(imageThumb.thumbId);
  }
}
