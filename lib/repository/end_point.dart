const T1 = 'https://t1.abilia-gbg.se';
const WHALE = 'https://whale.abilia-gbg.se';
const PROD = 'https://myabilia.com';
const Map<String,String> backEndEnviorments = {
  'T1': T1,
  'Whale': WHALE,
  'Prod': PROD,
  // 'local': '127.0.0.1:9103',
  };

String thumbImageUrl(String baseUrl, int userId, String imageFileId) =>
    '$baseUrl/api/v1/data/$userId/storage/image/thumb/$imageFileId';

Map<String, String> authHeader(String token) => {'X-Auth-Token': token};
