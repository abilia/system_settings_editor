import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/repository/push.dart';
import 'package:seagull/utils/licenses.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required this.authenticationBloc,
    required this.pushService,
    required this.clockBloc,
  }) : super(LoginState.initial());

  static final _log = Logger((LoginCubit).toString());

  final AuthenticationBloc authenticationBloc;
  final FirebasePushService pushService;
  final ClockBloc clockBloc;

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

  void loginButtonPressed() async {
    emit(state.loading());
    if (!state.isUsernameValid) {
      emit(state.failure(cause: LoginFailureCause.noUsername));
      return;
    }
    if (!state.isPasswordValid) {
      emit(state.failure(cause: LoginFailureCause.noPassword));
      return;
    }
    final authState = authenticationBloc.state;
    try {
      final pushToken = await pushService.initPushToken();
      if (pushToken == null) throw 'push token null';
      final loginInfo = await authState.userRepository.authenticate(
        username: state.username.trim(),
        password: state.password.trim(),
        pushToken: pushToken,
        time: clockBloc.state,
      );
      final licenses =
          await authState.userRepository.getLicensesFromApi(loginInfo.token);
      if (licenses.anyValidLicense(clockBloc.state)) {
        authenticationBloc.add(LoggedIn(loginInfo: loginInfo));
        emit(const LoginSucceeded());
      } else {
        emit(state.failure(
          cause: licenses.anyMemoplannerLicense()
              ? LoginFailureCause.licenseExpired
              : LoginFailureCause.noLicense,
        ));
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

  static bool usernameValid(String username) => username.length > 2;

  static bool passwordValid(String password) => password.length > 7;
}
