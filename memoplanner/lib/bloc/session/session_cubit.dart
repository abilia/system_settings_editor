import 'package:collection/collection.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/session_repository.dart';

class SessionCubit extends Cubit<Session> {
  SessionCubit({required this.sessionRepository})
      : super(sessionRepository.session) {
    _initialize();
  }

  final SessionRepository sessionRepository;
  final _log = Logger((SessionCubit).toString());

  Future<void> _initialize() async {
    try {
      final sessions = await sessionRepository.fetchSessions();
      final mp4Session = sessions.firstWhereOrNull(
          (s) => s.type == 'flutter' && s.app == 'memoplanner');
      await sessionRepository.setSession(mp4Session);
      emit(mp4Session ?? Session.empty());
    } on FetchSessionsException catch (e) {
      _log.warning(
          'Could not fetch sessions from backend with status code ${e.statusCode}');
    } catch (e) {
      _log.warning('Could not fetch sessions from backend $e');
    }
  }
}
