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

class RequestPermission extends RequestPermissions {
  RequestPermission(Permission permission) : super([permission]);
}

class CheckStatusForPermissions extends PermissionEvent {
  const CheckStatusForPermissions(List<Permission> permissions)
      : super(permissions);
}

class CheckStatusForPermission extends CheckStatusForPermissions {
  CheckStatusForPermission(Permission permission) : super([permission]);
}
