import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:rxdart/rxdart.dart';

part 'login_dialog_state.dart';

class LoginDialogCubit extends Cubit<LoginDialogState> {
  late final StreamSubscription _termsOfUseSubscription;
  late final StreamSubscription _sortableSubscription;

  LoginDialogCubit({
    required TermsOfUseCubit termsOfUseCubit,
    required SortableBloc sortableBloc,
    required PermissionCubit permissionCubit,
  }) : super(LoginDialogNotReady.initial()) {
    _termsOfUseSubscription = termsOfUseCubit.stream
        .whereType<TermsOfUseLoaded>()
        .listen((_) => _onTermsOfUseLoaded());
    _sortableSubscription = sortableBloc.stream
        .whereType<SortablesLoaded>()
        .listen((_) => _onSortablesLoaded());
  }

  void _onTermsOfUseLoaded() {
    final s = state;
    if (s is LoginDialogNotReady) {
      emit(s.copyWith(termsOfUseLoaded: true));
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
      emit(const LoginDialogReady());
    }
  }

  @override
  Future<void> close() {
    _termsOfUseSubscription.cancel();
    _sortableSubscription.cancel();
    return super.close();
  }
}
