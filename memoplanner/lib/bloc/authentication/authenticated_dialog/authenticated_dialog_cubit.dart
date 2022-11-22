import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:rxdart/rxdart.dart';

part 'authenticated_dialog_state.dart';

class AuthenticatedDialogCubit extends Cubit<AuthenticatedDialogState> {
  late final StreamSubscription _sortableSubscription;
  final TermsOfUseRepository termsOfUseRepository;
  final SortableBloc sortableBloc;
  final PermissionCubit permissionCubit;
  final bool newlyLoggedIn;
  final _log = Logger((AuthenticatedDialogCubit).toString());

  bool get showTermsOfUseDialog => !state.termsOfUse.allAccepted;

  bool get showStarterSetDialog {
    final sortableState = sortableBloc.state;
    final showStarterSet =
        sortableState is SortablesLoaded && sortableState.sortables.isEmpty;
    return showStarterSet && newlyLoggedIn;
  }

  bool get showFullscreenAlarmDialog {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final fullscreenAlarmEnabled = Config.isMPGO && isAndroid;
    final permissionStatus = permissionCubit.state.status;
    final showFullscreenAlarm = fullscreenAlarmEnabled &&
        permissionStatus.containsKey(Permission.systemAlertWindow) &&
        !(permissionStatus[Permission.systemAlertWindow]?.isGranted ?? false);
    return showFullscreenAlarm && newlyLoggedIn;
  }

  AuthenticatedDialogCubit({
    required this.termsOfUseRepository,
    required this.sortableBloc,
    required this.permissionCubit,
    required this.newlyLoggedIn,
  }) : super(AuthenticatedDialogNotReady.initial()) {
    _sortableSubscription = sortableBloc.stream
        .whereType<SortablesLoaded>()
        .listen((_) => _onSortablesLoaded());
    _loadTermsOfUse();
  }

// If fetching terms of use fails and throws an exception,
// TermsOfUse.accepted will be emitted thus not triggering the TermsOfUseDialog.
  Future<void> _loadTermsOfUse() async {
    TermsOfUse termsOfUse = TermsOfUse.accepted();
    try {
      termsOfUse = await termsOfUseRepository.loadTermsOfUse();
    } on FetchTermsOfUseException catch (e) {
      _log.warning(
          'Could not fetch terms of use from backend with status code ${e.statusCode}');
    } catch (e) {
      _log.warning('Could not fetch terms of use from backend $e');
    }
    _onTermsOfUseLoaded(termsOfUse);
  }

  Future<void> saveTermsOfUse(TermsOfUse termsOfUse) =>
      termsOfUseRepository.saveTermsOfUse(termsOfUse);

  void _onTermsOfUseLoaded(TermsOfUse termsOfUse) {
    final s = state;
    if (s is AuthenticatedDialogNotReady) {
      emit(s.copyWith(termsOfUse: termsOfUse, termsOfUseLoaded: true));
    }
    _checkIfReady();
  }

  void _onSortablesLoaded() {
    final s = state;
    if (s is AuthenticatedDialogNotReady) {
      emit(s.copyWith(sortablesLoaded: true));
    }
    _checkIfReady();
  }

  void _checkIfReady() {
    final s = state;
    if (s is AuthenticatedDialogNotReady && s.dialogsReady) {
      emit(AuthenticatedDialogReady(s.termsOfUse));
    }
  }

  @override
  Future<void> close() {
    _sortableSubscription.cancel();
    return super.close();
  }
}
