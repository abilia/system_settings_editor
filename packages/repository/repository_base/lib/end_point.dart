const prod = 'https://myabilia.com', prodName = 'PROD', testName = 'TEST';

const backendEnvironments = {
  prod: prodName,
  'https://staging.myabilia.com': 'STAGING',
  'https://test.myabilia.com': testName,
  'https://whale.abilia-gbg.se': 'Whale',
  'https://t1.abilia-gbg.se': 'T1',
};

String backendName(String endpoint, [String fallback = 'LOCAL']) =>
    backendEnvironments[endpoint] ?? fallback;

String fileIdUrl(String baseUrl, int userId, String imageFileId) =>
    '$baseUrl/api/v1/data/$userId/storage/file/id/$imageFileId';

String profileImageUrl(String baseUrl, String imageFileId, {int size = 400}) =>
    '$baseUrl/open/v1/file/$imageFileId?size=$size';

Map<String, String> authHeader(String? token) =>
    token != null ? {'X-Auth-Token': token} : {};

const Map<String, String> jsonHeader = {'Content-Type': 'application/json'};
