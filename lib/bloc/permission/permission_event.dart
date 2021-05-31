// @dart=2.9

part of 'permission_bloc.dart';

abstract class PermissionEvent extends Equatable with Info {
  final List<Permission> permissions;
  const PermissionEvent(this.permissions);

  @override
  List<Object> get props => [permissions];
  @override
  bool get stringify => true;
}

class RequestPermissions extends PermissionEvent {
  const RequestPermissions(List<Permission> permissions) : super(permissions);
}

class CheckStatusForPermissions extends PermissionEvent {
  const CheckStatusForPermissions(List<Permission> permissions)
      : super(permissions);
}
