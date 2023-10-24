import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:sqflite/sqlite_api.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required this.authenticationBloc,
    required this.pushService,
    required this.clockCubit,
    required this.userRepository,
    required this.database,
    required this.allowExpiredLicense,
    required this.product,
  }) : super(LoginState.initial());

  static final _log = Logger((LoginCubit).toString());

  final Database database;
  final AuthenticationBloc authenticationBloc;
  final FirebasePushService pushService;
  final ClockCubit clockCubit;
  final UserRepository userRepository;
  final bool allowExpiredLicense;
  final Product product;

  void toggleObscurePassword() {
    emit(state.copyWith(
      obscurePassword: !state.obscurePassword,
    ));
  }

  void usernameChanged(String username) {
    emit(state.copyWith(
      username: username.trim(),
    ));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(
      password: password.trim(),
    ));
  }

  void clearFailure() {
    emit(state.copyWith());
  }

  Future<void> loginButtonPressed() {
    return _login();
  }

  Future<void> licenseExpiredWarningConfirmed() =>
      _login(licenseExpiredConfirmed: true);

  Future<void> _login({bool licenseExpiredConfirmed = false}) async {
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
        time: clockCubit.state,
      );
      await userRepository.persistLoginInfo(loginInfo);
      await _checkValidLicense(licenseExpiredConfirmed);
    } catch (error) {
      final authenticationFailureCause = _getAuthenticationFailureCause(error);
      if (isClosed) return;
      emit(state.failure(cause: authenticationFailureCause));
    }
  }

  Future<LoginFailureCause?> _getPreLoginFailureCause() async {
    if (!await DatabaseRepository.isEmpty(database)) {
      await DatabaseRepository.clearAll(database);
      if (!await DatabaseRepository.isEmpty(database)) {
        return LoginFailureCause.notEmptyDatabase;
      }
    }
    if (!state.isUsernameValid) {
      return LoginFailureCause.noUsername;
    }
    if (!state.isPasswordValid) {
      return LoginFailureCause.noPassword;
    }
    return null;
  }

  LoginFailureCause _getAuthenticationFailureCause(Object error) {
    switch (error.runtimeType) {
      case UnauthorizedException:
        return LoginFailureCause.credentials;
      case WrongUserTypeException:
        return LoginFailureCause.unsupportedUserType;
      case TooManyAttempsException:
        return LoginFailureCause.tooManyAttempts;
      default:
        _log.severe('could not login: $error');
        return LoginFailureCause.noConnection;
    }
  }

  Future<void> _checkValidLicense(bool licenseExpiredConfirmed) async {
    final licenses = await userRepository.getLicensesFromApi(product);
    final hasValidLicense = licenses.anyValidLicense(clockCubit.state);
    final hasLicense = licenses.isNotEmpty;
    final hasLicenseAndLicenseExpiredConfirmed =
        allowExpiredLicense && hasLicense && licenseExpiredConfirmed;

    if (hasValidLicense || hasLicenseAndLicenseExpiredConfirmed) {
      return _loginSuccess();
    }
    final licenceFailureCause = _getLicenceFailureCause(hasLicense);
    emit(state.failure(cause: licenceFailureCause));
  }

  LoginFailureCause _getLicenceFailureCause(bool hasLicense) {
    if (allowExpiredLicense && hasLicense) {
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
