import 'dart:async';

import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

part 'license_state.dart';

class LicenseCubit extends Cubit<LicenseState> {
  final ClockBloc clockBloc;
  late final StreamSubscription pushSubscription;
  late final StreamSubscription authSubscription;
  LicenseCubit({
    required this.userRepository,
    required this.clockBloc,
    required PushCubit pushCubit,
    required AuthenticationBloc authenticationBloc,
  }) : super(LicensesNotLoaded()) {
    pushSubscription = pushCubit.stream.listen((state) {
      if (state is PushReceived) {
        reloadLicenses();
      }
    });

    authSubscription = authenticationBloc.stream.listen((state) {
      if (state is Authenticated) {
        reloadLicenses();
      }
    });
  }

  final UserRepository userRepository;

  void reloadLicenses() async {
    final licenses = await userRepository.getLicenses();
    if (licenses.anyValidLicense(clockBloc.state)) {
      emit(ValidLicense());
    } else {
      emit(NoValidLicense());
    }
  }

  @override
  Future<void> close() async {
    await pushSubscription.cancel();
    await authSubscription.cancel();
    return super.close();
  }
}
