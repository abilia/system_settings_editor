import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:rxdart/rxdart.dart';

part 'authenticated_dialog_state.dart';

class AuthenticatedDialogCubit extends Cubit<AuthenticatedDialogState> {
  StreamSubscription? _sortableSubscription, _permissionSubscription;
  final TermsOfUseRepository termsOfUseRepository;

  AuthenticatedDialogCubit({
    required this.termsOfUseRepository,
    required SortableBloc sortableBloc,
    required PermissionCubit permissionCubit,
    required bool newlyLoggedIn,
  }) : super(AuthenticatedDialogState(
          starterSetLoaded: !newlyLoggedIn,
          fullscreenAlarmLoaded: !newlyLoggedIn ||
              !Config.isMPGO ||
              defaultTargetPlatform != TargetPlatform.android,
        )) {
    if (!state.starterSetLoaded) {
      _sortableSubscription = sortableBloc.stream
          .whereType<SortablesLoaded>()
          .take(1)
          .listen(_onSortableLoaded);
    }
    if (!state.fullscreenAlarmLoaded) {
      _permissionSubscription = permissionCubit.stream
          .where((state) => state is PermissionsChecked)
          .take(1)
          .listen(_onPermissionChanged);
    }
  }

  Future<void> loadTermsOfUse() async {
    final termsAccepted = await termsOfUseRepository.isTermsOfUseAccepted();
    if (isClosed) return;
    emit(state.copyWith(termsOfUse: !termsAccepted));
  }

  void _onPermissionChanged(PermissionState permissionState) {
    emit(
      state.copyWith(
        fullscreenAlarm:
            permissionState.status[Permission.systemAlertWindow]?.isGranted !=
                true,
      ),
    );
  }

  void _onSortableLoaded(SortablesLoaded sortableState) {
    emit(
      state.copyWith(
        starterSet: sortableState.sortables.isEmpty,
      ),
    );
  }

  Future<void> acceptTermsOfUse() => termsOfUseRepository.acceptTermsOfUse();

  @override
  Future<void> close() {
    _sortableSubscription?.cancel();
    _permissionSubscription?.cancel();
    return super.close();
  }
}
