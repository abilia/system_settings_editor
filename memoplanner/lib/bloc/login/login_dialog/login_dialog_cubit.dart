import 'dart:async';

import 'package:http/http.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:rxdart/rxdart.dart';

part 'login_dialog_state.dart';

class LoginDialogCubit extends Cubit<LoginDialogState> {
  late final StreamSubscription _sortableSubscription;
  final TermsOfUseRepository termsOfUseRepository;
  final _log = Logger((LoginDialogCubit).toString());

  LoginDialogCubit({
    required this.termsOfUseRepository,
    required SortableBloc sortableBloc,
    required PermissionCubit permissionCubit,
  }) : super(LoginDialogNotReady.initial()) {
    _sortableSubscription = sortableBloc.stream
        .whereType<SortablesLoaded>()
        .listen((_) => _onSortablesLoaded());
    _loadTermsOfUse();
  }

// If fetching terms of use fails and throws an exception,
// TermsOfUse.accepted will be emitted thus not triggering the TermsOfUseDialog on login.
  Future<void> _loadTermsOfUse() async {
    TermsOfUse termsOfUse = TermsOfUse.accepted();
    try {
      termsOfUse = await termsOfUseRepository.fetchTermsOfUse();
    } on FetchTermsOfUseException catch (e) {
      _log.warning(
          'Could not fetch terms of use from backend with status code ${e.statusCode}');
    } catch (e) {
      _log.warning('Could not fetch terms of use from backend $e');
    }
    _onTermsOfUseLoaded(termsOfUse);
  }

  Future<Response> postTermsOfUse(TermsOfUse termsOfUse) =>
      termsOfUseRepository.postTermsOfUse(termsOfUse);

  void _onTermsOfUseLoaded(TermsOfUse termsOfUse) {
    final s = state;
    if (s is LoginDialogNotReady) {
      emit(s.copyWith(termsOfUse: termsOfUse, termsOfUseLoaded: true));
    }
    _checkIfReady();
  }

  void _onSortablesLoaded() {
    final s = state;
    if (s is LoginDialogNotReady) {
      emit(s.copyWith(sortablesLoaded: true));
    }
    _checkIfReady();
  }

  void _checkIfReady() {
    final s = state;
    if (s is LoginDialogNotReady && s.dialogsReady) {
      emit(LoginDialogReady(s.termsOfUse));
    }
  }

  @override
  Future<void> close() {
    _sortableSubscription.cancel();
    return super.close();
  }
}
