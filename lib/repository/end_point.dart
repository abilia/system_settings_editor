const BASE_URL = 'https://t1.abilia-gbg.se';

String thumbImageUrl(int userId, String imageFileId) =>
    '$BASE_URL/api/v1/data/$userId/storage/image/thumb/$imageFileId';

Map<String, String> authHeader(String token) => {
      'X-Auth-Token': token,
    };
