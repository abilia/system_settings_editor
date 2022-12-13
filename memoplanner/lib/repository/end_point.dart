import 'package:memoplanner/models/all.dart';

const prod = 'https://myabilia.com', prodName = 'PROD', testName = 'TEST';

const backendEnvironments = {
  prod: prodName,
  'https://whale.abilia-gbg.se': 'STAGING',
  'https://t1.abilia-gbg.se': testName,
};

String backendName(String endpoint, [String fallback = 'LOCAL']) =>
    backendEnvironments[endpoint] ?? fallback;

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

Map<String, String> authHeader(String? token) =>
    token != null ? {'X-Auth-Token': token} : {};

const Map<String, String> jsonHeader = {'Content-Type': 'application/json'};

const Map<String, String> jsonHeaderWithKey = {
  'Content-Type': 'application/json',
  'api-key': 'huyf72P00mf8Hy53k',
};
