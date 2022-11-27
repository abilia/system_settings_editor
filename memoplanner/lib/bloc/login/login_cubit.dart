import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/exceptions.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required this.authenticationBloc,
    required this.pushService,
    required this.clockBloc,
    required this.userRepository,
  }) : super(LoginState.initial());

  static final _log = Logger((LoginCubit).toString());

  final AuthenticationBloc authenticationBloc;
  final FirebasePushService pushService;
  final ClockBloc clockBloc;
  final UserRepository userRepository;

  void usernameChanged(String username) {
    emit(state.copyWith(
      username: username,
    ));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(
      password: password,
    ));
  }

  void clearFailure() {
    emit(state.copyWith());
  }

  Future<void> login({licenseExpiredConfirmed = false}) {
    return _login(licenseExpiredConfirmed);
  }

  Future<void> _login(bool licenseExpiredConfirmed) async {
    emit(state.loading());
    final preLoginFailureCause = await _getPreLoginFailureCause();
    if (preLoginFailureCause != null) {
      return emit(state.failure(cause: preLoginFailureCause));
    }
    await _authenticate(licenseExpiredConfirmed);
  }

  Future<void> _authenticate(bool licenseExpiredConfirmed) async {
    try {
      final pushToken = await pushService.initPushToken();
      if (pushToken == null) throw 'push token null';
      final loginInfo = await userRepository.authenticate(
        username: state.username.trim(),
        password: state.password.trim(),
        pushToken: pushToken,
        time: clockBloc.state,
      );
      userRepository.persistLoginInfo(loginInfo);
      _checkValidLicense(licenseExpiredConfirmed);
    } catch (error) {
      final authenticationFailureCause = _getAuthenticationFailureCause(error);
      emit(state.failure(cause: authenticationFailureCause));
    }
  }

  Future<LoginFailureCause?> _getPreLoginFailureCause() async {
    if (!state.isUsernameValid) {
      return LoginFailureCause.noUsername;
    }
    if (!state.isPasswordValid) {
      return LoginFailureCause.noPassword;
    }
    if (!await DatabaseRepository.isEmpty(GetIt.I<Database>())) {
      await DatabaseRepository.clearAll(GetIt.I<Database>());
      if (!await DatabaseRepository.isEmpty(GetIt.I<Database>())) {
        return LoginFailureCause.notEmptyDatabase;
      }
    }
    return null;
  }

  LoginFailureCause _getAuthenticationFailureCause(Object error) {
    switch (error.runtimeType) {
      case UnauthorizedException:
        return LoginFailureCause.credentials;
      case WrongUserTypeException:
        return LoginFailureCause.unsupportedUserType;
      default:
        _log.severe('could not login: $error');
        return LoginFailureCause.noConnection;
    }
  }

  Future<void> _checkValidLicense(bool licenseExpiredConfirmed) async {
    final licenses = await userRepository.getLicensesFromApi();
    final hasValidLicense = licenses.anyValidLicense(clockBloc.state);
    final hasMemoplannerLicense = licenses.anyMemoplannerLicense();
    final hasMPLicenseAndLicenseExpiredConfirmed =
        Config.isMP && hasMemoplannerLicense && licenseExpiredConfirmed;

    if (hasValidLicense || hasMPLicenseAndLicenseExpiredConfirmed) {
      return _loginSuccess();
    }
    final licenceFailureCause = _getLicenceFailureCause(hasMemoplannerLicense);
    emit(state.failure(cause: licenceFailureCause));
  }

  LoginFailureCause _getLicenceFailureCause(bool hasMemoplannerLicense) {
    if (Config.isMP && hasMemoplannerLicense) {
      return LoginFailureCause.licenseExpired;
    }
    return LoginFailureCause.noLicense;
  }

  void _loginSuccess() {
    authenticationBloc.add(const LoggedIn());
    emit(const LoginSucceeded());
  }

  static const minUsernameLength = 3;

  static bool usernameValid(String username) =>
      username.length >= minUsernameLength;

  static bool passwordValid(String password) => password.isNotEmpty;
}
