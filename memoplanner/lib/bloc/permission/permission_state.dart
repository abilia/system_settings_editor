part of 'permission_cubit.dart';

abstract class PermissionState extends Equatable {
  final UnmodifiableMapView<Permission, PermissionStatus> status;

  const PermissionState(this.status);

  @visibleForTesting
  PermissionsChecked update(Map<Permission, PermissionStatus> newStates) {
    return PermissionsChecked(
      UnmodifiableMapView(
        Map.of(status)
          ..addAll(
            {
              for (final newState in newStates.entries)
                if (!newState.value.isDenied ||
                    status[newState.key] != PermissionStatus.permanentlyDenied)
                  newState.key: newState.value,
            },
          ),
      ),
    );
  }

  bool get notificationDenied =>
      status[Permission.notification]?.isDeniedOrPermanentlyDenied ?? false;

  bool get fullscreenNotGranted =>
      PermissionCubit.allPermissions.contains(Permission.systemAlertWindow) &&
      !(status[Permission.systemAlertWindow]?.isGranted ?? false);

  bool get importantPermissionMissing =>
      notificationDenied || fullscreenNotGranted;

  @override
  List<Object> get props => [status];

  @override
  bool get stringify => true;
}

class PermissionsUnchecked extends PermissionState {
  PermissionsUnchecked() : super(UnmodifiableMapView({}));
}

class PermissionsChecked extends PermissionState {
  const PermissionsChecked(super.status);
}
