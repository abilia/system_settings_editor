import 'dart:async';

import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

part 'license_event.dart';
part 'license_state.dart';

class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  final ClockBloc clockBloc;
  late final StreamSubscription pushSubscription;
  late final StreamSubscription authSubscription;
  LicenseBloc({
    required this.userRepository,
    required this.clockBloc,
    required PushBloc pushBloc,
    required AuthenticationBloc authenticationBloc,
  }) : super(LicensesNotLoaded()) {
    pushSubscription = pushBloc.stream.listen((state) {
      if (state is PushReceived) {
        add(ReloadLicenses());
      }
    });

    authSubscription = authenticationBloc.stream.listen((state) {
      if (state is Authenticated) {
        add(ReloadLicenses());
      }
    });
  }

  final UserRepository userRepository;

  @override
  Stream<LicenseState> mapEventToState(
    LicenseEvent event,
  ) async* {
    if (event is ReloadLicenses) {
      final licenses = await userRepository.getLicenses();
      if (licenses.anyValidLicense(clockBloc.state)) {
        yield ValidLicense();
      } else {
        yield NoValidLicense();
      }
    }
  }

  @override
  Future<void> close() async {
    await pushSubscription.cancel();
    await authSubscription.cancel();
    return super.close();
  }
}
