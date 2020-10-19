part of 'permission_bloc.dart';

class PermissionState extends Equatable {
  const PermissionState(this.status);

  factory PermissionState.empty() => PermissionState(UnmodifiableMapView({}));

  @visibleForTesting
  factory PermissionState.from(Map<Permission, PermissionStatus> statuses) =>
      PermissionState(
          UnmodifiableMapView(statuses._mapiOSDeniedToPermanentlyDenied));

  final UnmodifiableMapView<Permission, PermissionStatus> status;

  bool get photosIsGrantedOrUndetermined =>
      status[Platform.isAndroid ? Permission.storage : Permission.photos]
          .isGrantedOrUndetermined;

  bool get notificationDenied =>
      status[Permission.notification].isDeniedOrPermenantlyDenied;

  PermissionState _update(Map<Permission, PermissionStatus> newStates) =>
      PermissionState(
        UnmodifiableMapView(
          Map.of(status)
            ..addAll(
              newStates._mapiOSDeniedToPermanentlyDenied,
            ),
        ),
      );

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
