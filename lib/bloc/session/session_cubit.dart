import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/session_repository.dart';

class SessionCubit extends Cubit<bool> {
  SessionCubit({required this.sessionRepository}) : super(false) {
    _initialize();
  }

  final SessionRepository sessionRepository;

  void _initialize() async {
    emit(await sessionRepository.hasMP4Session());
  }
}
