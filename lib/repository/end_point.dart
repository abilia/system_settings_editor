import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';

const T1 = 'https://t1.abilia-gbg.se';
const WHALE = 'https://whale.abilia-gbg.se';
const PROD = 'https://myabilia.com';
const LOCAL = 'http://172.20.10.8:9103';
const Map<String, String> backEndEnviorments = {
  'Prod': PROD,
  'Whale': WHALE,
  'T1': T1,
  'Local': LOCAL,
};

String fileIdUrl(String baseUrl, int userId, String imageFileId) =>
    '$baseUrl/api/v1/data/$userId/storage/file/id/$imageFileId';

String imageThumbUrl({
  @required String baseUrl,
  @required int userId,
  @required String imageFileId,
  @required String imagePath,
  int size = ImageThumb.THUMB_SIZE,
}) =>
    imageFileId != null
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
  @required String baseUrl,
  @required int userId,
  @required String imageFileId,
  int size = ImageThumb.THUMB_SIZE,
}) =>
    '$baseUrl/api/v1/data/$userId/storage/image/thumb/$imageFileId?height=$size&width=$size';

String imagePathUrl(String baseUrl, int userId, String imagePath) =>
    '$baseUrl/api/v1/data/$userId/storage/root/$imagePath';

String imageThumbPathUrl({
  @required String baseUrl,
  @required int userId,
  @required String imagePath,
  int size = ImageThumb.THUMB_SIZE,
}) =>
    '$baseUrl/api/v1/data/$userId/storage/thumb/$imagePath?height=$size&width=$size';

String profileImageUrl(String baseUrl, String imageFileId, {int size = 400}) =>
    '$baseUrl/open/v1/file/$imageFileId?size=$size';

Map<String, String> authHeader(String token) => {'X-Auth-Token': token};

Map<String, String> jsonAuthHeader(String token) =>
    {'X-Auth-Token': token, 'Content-Type': 'application/json'};
