part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
}

class AuthenticationUninitialized extends AuthenticationState {}

class AuthenticationInitialized extends AuthenticationState {
  final UserRepository userRepository;
  AuthenticationInitialized(this.userRepository);
  @override
  List<Object> get props => [userRepository];
  @override
  String toString() =>
      'AuthenticationInitialized {userRepository: $userRepository}';
}

class Authenticated extends AuthenticationInitialized {
  final String token;
  final int userId;
  final bool newlyLoggedIn;
  Authenticated(
      {@required this.token,
      @required this.userId,
      this.newlyLoggedIn = false,
      @required UserRepository userRepository})
      : super(userRepository);
  @override
  List<Object> get props => [userRepository, token, userId, newlyLoggedIn];
  @override
  String toString() =>
      'Authenticated {userRepository: $userRepository, token: $token, userId: $userId}';
}

class Unauthenticated extends AuthenticationInitialized {
  final LoggedOutReason loggedOutReason;
  Unauthenticated(
    UserRepository userRepository, {
    this.loggedOutReason = LoggedOutReason.LOG_OUT,
  }) : super(userRepository);
  factory Unauthenticated.fromInitilized(
    AuthenticationInitialized state, {
    LoggedOutReason loggedOutReason = LoggedOutReason.LOG_OUT,
  }) =>
      Unauthenticated(
        state.userRepository,
        loggedOutReason: loggedOutReason,
      );
  @override
  String toString() => 'Unauthenticated {userRepository: $userRepository}';
}

class AuthenticationLoading extends AuthenticationInitialized {
  AuthenticationLoading(UserRepository userRepository) : super(userRepository);
  factory AuthenticationLoading.fromInitilized(
          AuthenticationInitialized state) =>
      AuthenticationLoading(state.userRepository);
  @override
  String toString() =>
      'AuthenticationLoading {userRepository: $userRepository}';
}
