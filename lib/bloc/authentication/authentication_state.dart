part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  final UserRepository userRepository;
  AuthenticationState(this.userRepository);
  @override
  List<Object> get props => [userRepository];
  @override
  bool get stringify => true;
}

class AuthenticationLoading extends AuthenticationState {
  AuthenticationLoading(UserRepository userRepository) : super(userRepository);
}

class Authenticated extends AuthenticationState {
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
}

class Unauthenticated extends AuthenticationState {
  final LoggedOutReason loggedOutReason;
  Unauthenticated(
    UserRepository userRepository, {
    this.loggedOutReason = LoggedOutReason.LOG_OUT,
  }) : super(userRepository);

  @override
  List<Object> get props => [userRepository, loggedOutReason];
}
