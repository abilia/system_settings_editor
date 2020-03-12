part of 'user_file_bloc.dart';

abstract class UserFileState extends Equatable {
  const UserFileState();
}

class UserFileInitial extends UserFileState {
  @override
  List<Object> get props => [];
}
