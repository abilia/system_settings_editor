import 'package:calendar_repository/calendar.dart';
import 'package:calendar_repository/calendar_db.dart';
import 'package:logging/logging.dart';
import 'package:repo_base/repo_base.dart';
import 'package:utils/utils.dart';

class CalendarRepository extends Repository {
  static final _log = Logger((CalendarRepository).toString());

  final CalendarDb calendarDb;
  final int postApiVersion;

  const CalendarRepository({
    required super.baseUrlDb,
    required super.client,
    required this.calendarDb,
    this.postApiVersion = 1,
  });

  Future<void> fetchAndSetCalendar(int userId) async {
    try {
      if (await calendarDb.getCalendarId() == null) {
        final response = await client.post(
          '$baseUrl/api/v$postApiVersion/calendar/$userId?type=${CalendarDb.memoType}'
              .toUri(),
        );
        final calendarType = Calendar.fromJson(response.json());
        await calendarDb.insert(calendarType);
      }
    } catch (e, s) {
      _log.severe('could not fetch calendarId', e, s);
    }
  }
}
