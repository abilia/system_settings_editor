part of 'permission_cubit.dart';

class PermissionState extends Equatable {
  const PermissionState(this.status);

  factory PermissionState.empty() => PermissionState(UnmodifiableMapView({}));

  final UnmodifiableMapView<Permission, PermissionStatus> status;

  @visibleForTesting
  PermissionState update(Map<Permission, PermissionStatus> newStates) {
    return PermissionState(
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
