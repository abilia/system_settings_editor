import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/sessions_repository.dart';

part 'sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit({required this.sessionsRepository})
      : super(SessionsState(sessionsRepository.hasMP4Session()));

  final SessionsRepository sessionsRepository;
  final _log = Logger((SessionsCubit).toString());

  Future<void> initialize() async {
    try {
      final sessions = await sessionsRepository.fetchSessions();
      final hasMP4Session =
          sessions.any((s) => s.type == 'flutter' && s.app == 'memoplanner');
      await sessionsRepository.setHasMP4Session(hasMP4Session);
      emit(SessionsState(hasMP4Session));
    } on FetchSessionsException catch (e) {
      _log.warning(
          'Could not fetch sessions from backend with status code ${e.statusCode}');
    } catch (e) {
      _log.warning('Could not fetch sessions from backend $e');
    }
  }
}
