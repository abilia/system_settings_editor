library file_storage;

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_storage/image_thumb.dart';
import 'package:logging/logging.dart';

export 'package:file_storage/image_thumb.dart';

class FileStorage extends Equatable {
  final _log = Logger((FileStorage).toString());

  final String _dir;

  String get dir => _dir;

  static const folder = 'seagull';

  FileStorage(String directory) : _dir = directory;

  factory FileStorage.inDirectory(String? storageDirectory) =>
      FileStorage('$storageDirectory/$folder/');

  Future<void> storeFile(List<int> fileBytes, String fileName) async {
    final file = await File('$_dir$fileName').create(recursive: true);
    await file.writeAsBytes(fileBytes);
  }

  Future<void> storeImageThumb(
      List<int> fileBytes, ImageThumb imageThumb) async {
    return storeFile(fileBytes, imageThumb.thumbId);
  }

  File getFile(String id) {
    final path = '$_dir$id';
    return File(path);
  }

  File getImageThumb(ImageThumb imageThumb) {
    return getFile(imageThumb.thumbId);
  }

  Future deleteUserFolder() async {
    final userDirectory = Directory(_dir);
    if (await userDirectory.exists()) {
      try {
        return userDirectory.delete(recursive: true);
      } catch (e) {
        _log.severe('could not delete folder: $_dir');
      }
    }
  }

  // For mocking purpose
  Future<bool> exists(File file) => file.exists();

  /// iOS attachments files are moved into the attachment data store so that they can be accessed by all of the appropriate processes. (https://developer.apple.com/documentation/usernotifications/unnotificationattachment)
  /// So the file needs to be copied so the original won't get deleted
  /// the file ending .jpg is added to hint to iOS what file type the attachment is
  /// as flutter_local_notifications dont support adding the option UNNotificationAttachmentOptionsTypeHintKey as of 1.4.4+1
  final fileEnding = '_copy.jpg';
  final maxSizeInBytes = 10000000;
  Future<File?> copyImageThumbForNotification(String id) async {
    final thumb = getImageThumb(ImageThumb(id: id));
    if (!await thumb.exists()) {
      _log.warning('file $thumb does not extists');
      return null;
    }

    final sizeInBytes = await thumb.length();
    if (sizeInBytes > maxSizeInBytes) {
      _log.warning('$thumb is to large (over $maxSizeInBytes bytes)');
      return null;
    }

    return thumb.copy('$_dir$id$fileEnding');
  }

  @override
  List<Object?> get props => [_dir];
}