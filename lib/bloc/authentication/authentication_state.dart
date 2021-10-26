part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  final UserRepository userRepository;
  final bool forcedNewState;
  const AuthenticationState(this.userRepository, this.forcedNewState);
  @override
  List<Object> get props => [userRepository, forcedNewState];
  @override
  bool get stringify => true;
  AuthenticationState _forceNew();
}

class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading(UserRepository userRepository,
      [bool forcedNewState = false])
      : super(userRepository, forcedNewState);

  @override
  AuthenticationLoading _forceNew() =>
      AuthenticationLoading(userRepository, !forcedNewState);
}

class Authenticated extends AuthenticationState {
  final String token;
  final int userId;
  final bool newlyLoggedIn;
  const Authenticated({
    required this.token,
    required this.userId,
    this.newlyLoggedIn = false,
    required UserRepository userRepository,
    bool forcedNewState = false,
  }) : super(userRepository, forcedNewState);
  @override
  List<Object> get props => [token, userId, newlyLoggedIn, ...super.props];

  @override
  Authenticated _forceNew() => Authenticated(
        token: token,
        userId: userId,
        newlyLoggedIn: newlyLoggedIn,
        userRepository: userRepository,
        forcedNewState: !forcedNewState,
      );
}

class Unauthenticated extends AuthenticationState {
  final LoggedOutReason loggedOutReason;
  const Unauthenticated(
    UserRepository userRepository, {
    this.loggedOutReason = LoggedOutReason.logOut,
    bool forcedNewState = false,
  }) : super(userRepository, forcedNewState);

  @override
  List<Object> get props => [loggedOutReason, ...super.props];

  @override
  Unauthenticated _forceNew() => Unauthenticated(
        userRepository,
        loggedOutReason: loggedOutReason,
        forcedNewState: !forcedNewState,
      );
}
