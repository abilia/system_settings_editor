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

  bool get photosIsGrantedOrUndetermined =>
      status[Platform.isAndroid ? Permission.storage : Permission.photos]
          .isGrantedOrUndetermined;

  bool get notificationDenied =>
      status[Permission.notification].isDeniedOrPermenantlyDenied;

  bool get importantPermissionMissing =>
      notificationDenied ||
      (Platform.isAndroid && !status[Permission.systemAlertWindow].isGranted);

  @override
  List<Object> get props => [status];

  @override
  bool get stringify => true;
}

extension _PermissionStatusMapExtension on Map<Permission, PermissionStatus> {
  Map<Permission, PermissionStatus> get _mapiOSDeniedToPermanentlyDenied =>
      map((key, value) => MapEntry(key, value._iOSDeniedToPermanentlyDenied));
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isGrantedOrUndetermined =>
      this == null || isGranted || isUndetermined;

  PermissionStatus get _iOSDeniedToPermanentlyDenied =>
      Platform.isIOS && isDenied ? PermissionStatus.permanentlyDenied : this;
}
