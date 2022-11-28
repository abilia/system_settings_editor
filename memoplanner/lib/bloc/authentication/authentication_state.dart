part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  final bool forcedNewState;
  const AuthenticationState(this.forcedNewState);
  @override
  List<Object> get props => [forcedNewState];
  @override
  bool get stringify => true;
  AuthenticationState _forceNew();
}

class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading([bool forcedNewState = false])
      : super(forcedNewState);

  @override
  AuthenticationLoading _forceNew() => AuthenticationLoading(!forcedNewState);
}

class Authenticated extends AuthenticationState {
  final User user;
  final bool newlyLoggedIn;
  const Authenticated({
    required this.user,
    this.newlyLoggedIn = false,
    bool forcedNewState = false,
  }) : super(forcedNewState);
  @override
  List<Object> get props => [userId, newlyLoggedIn, ...super.props];
  int get userId => user.id;

  @override
  Authenticated _forceNew() => Authenticated(
        user: user,
        newlyLoggedIn: newlyLoggedIn,
        forcedNewState: !forcedNewState,
      );
}

class Unauthenticated extends AuthenticationState {
  final LoggedOutReason loggedOutReason;
  const Unauthenticated({
    this.loggedOutReason = LoggedOutReason.logOut,
    bool forcedNewState = false,
  }) : super(forcedNewState);

  @override
  List<Object> get props => [loggedOutReason, ...super.props];

  @override
  Unauthenticated _forceNew() => Unauthenticated(
        loggedOutReason: loggedOutReason,
        forcedNewState: !forcedNewState,
      );
}