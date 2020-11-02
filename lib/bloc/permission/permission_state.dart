part of 'permission_bloc.dart';

class PermissionState extends Equatable {
  const PermissionState(this.status);

  factory PermissionState.empty() => PermissionState(UnmodifiableMapView({}));

  final UnmodifiableMapView<Permission, PermissionStatus> status;

  @visibleForTesting
  PermissionState update(Map<Permission, PermissionStatus> newStates) =>
      PermissionState(
        UnmodifiableMapView(
          Map.of(status)
            ..addAll(
              newStates._mapiOSDeniedToPermanentlyDenied,
            ),
        ),
      );

  bool get notificationDenied =>
      status[Permission.notification].isDeniedOrPermenantlyDenied;

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

extension _PermissionStatusMapExtension on Map<Permission, PermissionStatus> {
  Map<Permission, PermissionStatus> get _mapiOSDeniedToPermanentlyDenied => map(
        (key, value) => MapEntry(
          key,
          Platform.isIOS && value.isDenied
              ? PermissionStatus.permanentlyDenied
              : value,
        ),
      );
}
