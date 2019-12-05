const T1 = 'https://t1.abilia-gbg.se';
const WHALE = 'https://whale.abilia-gbg.se';
const PROD = 'https://myabilia.com';
const Map<String,String> backEndEnviorments = {
  'T1': T1,
  'Whale': WHALE,
  'Prod': PROD,
  };

String thumbImageUrl(String baseUrl, int userId, String imageFileId, {int width = 56, int height = 56}) =>
    '$baseUrl/api/v1/data/$userId/storage/image/thumb/$imageFileId?width=$width&height=$height';
String imageUrl(String baseUrl, int userId, String imageFileId) =>
    '$baseUrl/api/v1/data/$userId/storage/file/id/$imageFileId';


Map<String, String> authHeader(String token) => {'X-Auth-Token': token};
