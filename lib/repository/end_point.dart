import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

const PROD = 'https://myabilia.com',
    WHALE = 'https://whale.abilia-gbg.se',
    T1 = 'https://t1.abilia-gbg.se',
    DEBUG = 'https://debug.abilia-gbg.se';
const Map<String, String> backEndEnvironments = {
  'Prod': PROD,
  'Whale': WHALE,
  'T1': T1,
  if (Config.release) 'Debug': DEBUG else 'Local': 'http://192.168.1.28:9103',
};

String fileIdUrl(String baseUrl, int userId, String imageFileId) =>
    '$baseUrl/api/v1/data/$userId/storage/file/id/$imageFileId';

String imageThumbUrl({
  required String baseUrl,
  required int userId,
  required String imageFileId,
  required String imagePath,
  int size = ImageThumb.THUMB_SIZE,
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
  int size = ImageThumb.THUMB_SIZE,
}) =>
    '$baseUrl/api/v1/data/$userId/storage/image/thumb/$imageFileId?height=$size&width=$size';

String imagePathUrl(String baseUrl, int userId, String imagePath) =>
    '$baseUrl/api/v1/data/$userId/storage/root/$imagePath';

String imageThumbPathUrl({
  required String baseUrl,
  required int userId,
  required String imagePath,
  int size = ImageThumb.THUMB_SIZE,
}) =>
    '$baseUrl/api/v1/data/$userId/storage/thumb/$imagePath?height=$size&width=$size';

String profileImageUrl(String baseUrl, String imageFileId, {int size = 400}) =>
    '$baseUrl/open/v1/file/$imageFileId?size=$size';

Map<String, String> authHeader(String token) => {'X-Auth-Token': token};

Map<String, String> jsonAuthHeader(String token) =>
    {'X-Auth-Token': token, 'Content-Type': 'application/json'};
