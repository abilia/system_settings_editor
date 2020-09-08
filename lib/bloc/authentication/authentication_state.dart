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
  Authenticated(
      {@required this.token,
      @required this.userId,
      @required UserRepository userRepository})
      : super(userRepository);
  @override
  List<Object> get props => [userRepository, token, userId];
  @override
  String toString() =>
      'Authenticated {userRepository: $userRepository, token: $token, userId: $userId}';
}

class InvalidLicense extends AuthenticationInitialized {
  final String token;
  final int userId;
  InvalidLicense(
      {@required this.token,
      @required this.userId,
      @required UserRepository userRepository})
      : super(userRepository);
  @override
  List<Object> get props => [userRepository, token, userId];
  @override
  String toString() =>
      'InvalidLicense {userRepository: $userRepository, token: $token, userId: $userId}';
}

class Unauthenticated extends AuthenticationInitialized {
  Unauthenticated(UserRepository userRepository) : super(userRepository);
  factory Unauthenticated.fromInitilized(AuthenticationInitialized state) =>
      Unauthenticated(state.userRepository);
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
