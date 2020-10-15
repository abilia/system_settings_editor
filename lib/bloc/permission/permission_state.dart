part of 'permission_bloc.dart';

class PermissionState extends Equatable {
  const PermissionState(this.status);
  final UnmodifiableMapView<Permission, PermissionStatus> status;

  PermissionState _update(Map<Permission, PermissionStatus> newStates) =>
      PermissionState(
        UnmodifiableMapView(Map.of(status)..addAll(newStates)),
      );

  @override
  List<Object> get props => [status];

  @override
  bool get stringify => true;
}
