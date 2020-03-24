const T1 = 'https://t1.abilia-gbg.se';
const WHALE = 'https://whale.abilia-gbg.se';
const PROD = 'https://myabilia.com';
const LOCAL = 'http://192.168.1.63:9103';
const Map<String, String> backEndEnviorments = {
  'T1': T1,
  'Whale': WHALE,
  'Prod': PROD,
  'Local': LOCAL,
};

String fileIdUrl(String baseUrl, int userId, String imageFileId) =>
    '$baseUrl/api/v1/data/$userId/storage/file/id/$imageFileId';

String imageThumbUrl(String baseUrl, int userId, String imageFileId, int height,
        int width) =>
    '$baseUrl/api/v1/data/$userId/storage/image/thumb/$imageFileId?height=$height&width=$width';

String imagePathUrl(String baseUrl, int userId, String imagePath) =>
    '$baseUrl/api/v1/data/$userId/storage/root/$imagePath';

String profileImageUrl(String baseUrl, String imageFileId, {int size = 400}) =>
    '$baseUrl/open/v1/file/$imageFileId?size=$size';

Map<String, String> authHeader(String token) => {'X-Auth-Token': token};

Map<String, String> jsonAuthHeader(String token) =>
    {'X-Auth-Token': token, 'Content-Type': 'application/json'};
