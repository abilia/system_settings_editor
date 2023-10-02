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
