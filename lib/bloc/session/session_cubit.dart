import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/session_repository.dart';

class SessionCubit extends Cubit<bool> {
  SessionCubit({required this.sessionRepository})
      : super(sessionRepository.hasMP4Session()) {
    _initialize();
  }

  final SessionRepository sessionRepository;
  final _log = Logger((SessionCubit).toString());

  void _initialize() async {
    try {
      final sessions = await sessionRepository.fetchSessions();
      final hasMP4Session =
          sessions.any((s) => s.type == 'flutter' && s.app == 'memoplanner');
      await sessionRepository.setHasMP4Session(hasMP4Session);
      emit(hasMP4Session);
    } on FetchSessoionsException catch (e) {
      _log.warning(
          'Could not fetch sessions from backend with status code ${e.statusCode}');
    } catch (e) {
      _log.warning('Could not fetch sessions from backend $e');
    }
  }
}
