import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/session_repository.dart';

class SessionCubit extends Cubit<bool> {
  SessionCubit({required this.sessionRepository})
      : super(sessionRepository.hasMP4Session()) {
    _initialize();
  }

  final SessionRepository sessionRepository;
  final _log = Logger((SessionCubit).toString());

  Future<void> _initialize() async {
    try {
      final sessions = await sessionRepository.fetchSessions();
      final hasMP4Session =
          sessions.any((s) => s.type == 'flutter' && s.app == 'memoplanner');
      await sessionRepository.setHasMP4Session(hasMP4Session);
      emit(hasMP4Session);
    } on FetchSessionsException catch (e) {
      _log.warning(
          'Could not fetch sessions from backend with status code ${e.statusCode}');
    } catch (e) {
      _log.warning('Could not fetch sessions from backend $e');
    }
  }
}
