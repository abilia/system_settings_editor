import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorage {
  static const folder = 'seagull';

  Future<void> storeFile(List<int> fileBytes, String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final file =
        await File('${directory.path}/$folder/$id').create(recursive: true);
    await file.writeAsBytes(fileBytes);
  }

  Future<File> getFile(String id) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$folder/$id');
  }
}
