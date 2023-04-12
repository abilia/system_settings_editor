import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'password_state.dart';

class PasswordCubit extends Cubit<PasswordState> {
  final bool Function(String value)? validator;
  PasswordCubit(
    String password,
    this.validator,
  ) : super(PasswordState(password, true, validator?.call(password) == true));

  void toggleHidden() => emit(state.copyWith(hide: !state.hide));

  void changePassword(String newPassword) => emit(
        state.copyWith(
          password: newPassword,
          valid: validator?.call(newPassword) == true,
        ),
      );
}
