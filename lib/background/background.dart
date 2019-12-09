import 'package:http/http.dart';
import 'package:seagull/db/activities_db.dart';
import 'package:seagull/db/baseurl_db.dart';
import 'package:seagull/db/user_db.dart';
import 'package:seagull/repository/activities_repository.dart';
import 'package:seagull/repository/user_repository.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  final userDb = UserDb();
  final baseUrlDb = BaseUrlDb();
  final baseUrl = await baseUrlDb.getBaseUrl();
  final user = await userDb.getUser();
  final userRepository = UserRepository();
  final r = ActivityRepository(
    baseUrl: baseUrl,
    client: Client(),
    activitiesDb: ActivityDb(),
    userId: user.id,
  );
}
