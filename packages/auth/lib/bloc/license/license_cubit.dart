import 'dart:async';

import 'package:auth/bloc/all.dart';
import 'package:auth/licenses_extensions.dart';
import 'package:auth/models/license.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull_clock/clock_bloc.dart';

part 'license_state.dart';

class LicenseCubit extends Cubit<LicenseState> {
  final ClockBloc clockBloc;
  final LicenseType licenseType;
  late final StreamSubscription pushSubscription;
  late final StreamSubscription authSubscription;
  LicenseCubit({
    required this.userRepository,
    required this.clockBloc,
    required this.licenseType,
    required PushCubit pushCubit,
    required AuthenticationBloc authenticationBloc,
  }) : super(LicensesNotLoaded()) {
    pushSubscription = pushCubit.stream.listen((state) => reloadLicenses());
    authSubscription = authenticationBloc.stream.listen((state) {
      if (state is Authenticated) {
        reloadLicenses();
      }
    });
  }

  final UserRepository userRepository;

  bool get validLicense => state is ValidLicense;

  Future<void> reloadLicenses() async {
    final licenses = await userRepository.getLicenses();
    if (licenses.anyValidLicense(clockBloc.state, licenseType)) {
      emit(ValidLicense());
    } else if (licenses.anyLicense(licenseType)) {
      emit(NoValidLicense());
    } else {
      emit(NoLicense());
    }
  }

  @override
  Future<void> close() async {
    await pushSubscription.cancel();
    await authSubscription.cancel();
    return super.close();
  }
}
