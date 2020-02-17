const T1 = 'https://t1.abilia-gbg.se';
const WHALE = 'https://whale.abilia-gbg.se';
const PROD = 'https://myabilia.com';
const LOCAL = 'http://192.168.1.63:9103';
const Map<String, String> backEndEnviorments = {
  'T1': T1,
  'Whale': WHALE,
  'Prod': PROD,
};

String thumbImageUrl(String baseUrl, int userId, String imageFileId,
        {int width = 56, int height = 56}) =>
    '$baseUrl/api/v1/data/$userId/storage/image/thumb/$imageFileId?width=$width&height=$height';

String imageUrl(String baseUrl, int userId, String imageFileId) =>
    '$baseUrl/api/v1/data/$userId/storage/file/id/$imageFileId';

String profileImageUrl(String baseUrl, String imageFileId, {int size = 400}) =>
    '$baseUrl/open/v1/file/$imageFileId?size=$size';

Map<String, String> authHeader(String token) => {'X-Auth-Token': token};

Map<String, String> jsonAuthHeader(String token) =>
    {'X-Auth-Token': token, 'Content-Type': 'application/json'};
