import 'package:seagull/models/all.dart';

const prod = 'https://myabilia.com',
    whale = 'https://whale.abilia-gbg.se',
    t1 = 'https://t1-gce.abilia-gbg.se',
    debug = 'https://debug.abilia-gbg.se';
const Map<String, String> backEndEnvironments = {
  'Prod': prod,
  'Whale': whale,
  'T1': t1,
  'Debug': debug,
};

String fileIdUrl(String baseUrl, int userId, String imageFileId) =>
    '$baseUrl/api/v1/data/$userId/storage/file/id/$imageFileId';

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

String profileImageUrl(String baseUrl, String imageFileId, {int size = 400}) =>
    '$baseUrl/open/v1/file/$imageFileId?size=$size';

Map<String, String> authHeader(String token) => {'X-Auth-Token': token};

Map<String, String> jsonAuthHeader(String token) =>
    {'X-Auth-Token': token, 'Content-Type': 'application/json'};
