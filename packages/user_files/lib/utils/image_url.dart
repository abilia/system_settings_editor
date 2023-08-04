import 'package:file_storage/file_storage.dart';

String imageThumbUrl({
  required String baseUrl,
  required int userId,
  required String imageFileId,
  required String imagePath,
  int size = ImageThumb.thumbSize,
}) =>
    imageFileId.isNotEmpty
        ? imageThumbIdUrl(
            baseUrl: baseUrl,
            userId: userId,
            imageFileId: imageFileId,
            size: size,
          )
        : imageThumbPathUrl(
            baseUrl: baseUrl,
            userId: userId,
            imagePath: imagePath,
            size: size,
          );

String imageThumbIdUrl({
  required String baseUrl,
  required int userId,
  required String imageFileId,
  int size = ImageThumb.thumbSize,
}) =>
    '$baseUrl/api/v1/data/$userId/storage/image/thumb/$imageFileId?height=$size&width=$size';

String imagePathUrl(String baseUrl, int userId, String imagePath) =>
    '$baseUrl/api/v1/data/$userId/storage/root/$imagePath';

String imageThumbPathUrl({
  required String baseUrl,
  required int userId,
  required String imagePath,
  int size = ImageThumb.thumbSize,
}) =>
    '$baseUrl/api/v1/data/$userId/storage/thumb/$imagePath?height=$size&width=$size';