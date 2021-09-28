part of 'permission_bloc.dart';

class PermissionState extends Equatable {
  const PermissionState(this.status);

  factory PermissionState.empty() => PermissionState(UnmodifiableMapView({}));

  final UnmodifiableMapView<Permission, PermissionStatus> status;

  @visibleForTesting
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
      status[Permission.notification]?.isDeniedOrPermenantlyDenied ?? false;

  bool get fullscreenNotGranted =>
      !Platform.isIOS &&
      !(status[Permission.systemAlertWindow]?.isGranted ?? false);

  bool get importantPermissionMissing =>
      notificationDenied || fullscreenNotGranted;

  @override
  List<Object> get props => [status];

  @override
  bool get stringify => true;
}
