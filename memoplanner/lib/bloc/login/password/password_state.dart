part of 'password_cubit.dart';

class PasswordState extends Equatable {
  final String password;
  final bool hide;
  final bool valid;

  const PasswordState(this.password, this.hide, this.valid);
  PasswordState copyWith({
    String? password,
    bool? hide,
    bool? valid,
  }) =>
      PasswordState(
        password ?? this.password,
        hide ?? this.hide,
        valid ?? this.valid,
      );

  @override
  List<Object> get props => [password, hide, valid];

  @override
  bool get stringify => true;
}
