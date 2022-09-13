import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

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

  void loginButtonPressed() {
    _login();
  }

  void confirmLicenseExpiredWarning() {
    _login(confirmExpiredLicense: true);
  }

  void _login({bool confirmExpiredLicense = false}) async {
    emit(state.loading());
    if (!state.isUsernameValid) {
      emit(state.failure(cause: LoginFailureCause.noUsername));
      return;
    }
    if (!state.isPasswordValid) {
      emit(state.failure(cause: LoginFailureCause.noPassword));
      return;
    }
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
      final licenses = await userRepository.getLicensesFromApi();
      if (licenses.anyValidLicense(clockBloc.state)) {
        _loginSuccess();
      } else if (Config.isMP && licenses.anyMemoplannerLicense()) {
        if (confirmExpiredLicense) {
          _loginSuccess();
        } else {
          emit(state.failure(cause: LoginFailureCause.licenseExpired));
        }
      } else {
        emit(state.failure(cause: LoginFailureCause.noLicense));
      }
    } on UnauthorizedException {
      emit(state.failure(cause: LoginFailureCause.credentials));
    } on WrongUserTypeException {
      emit(state.failure(cause: LoginFailureCause.unsupportedUserType));
    } catch (error) {
      _log.severe('could not login: $error');
      emit(state.failure(cause: LoginFailureCause.noConnection));
    }
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
