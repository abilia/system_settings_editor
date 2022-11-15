import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
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
        .whereType<TermsOfUse>()
        .listen((termsOfUseState) {
      final s = state;
      if (s is LoginDialogNotReady) {
        emit(s.copyWith(termsOfUseLoaded: true));
      }
      checkIfReady();
    });
    _sortableSubscription =
        sortableBloc.stream.whereType<SortablesLoaded>().listen((event) {
      final s = state;
      if (s is LoginDialogNotReady) {
        emit(s.copyWith(sortablesLoaded: true));
      }
      checkIfReady();
    });
  }

  Future<void> checkIfReady() async {
    final s = state;
    if (s is LoginDialogNotReady && s.dialogsReady) {
      emit(LoginDialogReady());
    }
  }

  @override
  Future<void> close() {
    _termsOfUseSubscription.cancel();
    _sortableSubscription.cancel();
    return super.close();
  }
}
