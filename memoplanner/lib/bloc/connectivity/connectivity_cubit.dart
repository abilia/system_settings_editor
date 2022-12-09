import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/utils/all.dart';

export 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit({
    required this.connectivity,
    required this.baseUrlDb,
    required this.connectivityCheck,
  }) : super(const ConnectivityState.none()) {
    _onChangeSubscription =
        connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    checkConnectivity();
  }
  final BaseUrlDb baseUrlDb;
  final Connectivity connectivity;
  final ConnectivityCheck connectivityCheck;

  late final StreamSubscription _onChangeSubscription;

  Future<void> checkConnectivity() async =>
      _onConnectivityChanged(await connectivity.checkConnectivity());

  Future _onConnectivityChanged(ConnectivityResult result) async {
    emit(ConnectivityState(result, state.isConnected));
    final connected = await connectivityCheck(baseUrlDb.baseUrl);
    if (isClosed) return;
    emit(ConnectivityState(result, connected));
  }

  @override
  Future<void> close() async {
    await _onChangeSubscription.cancel();
    return super.close();
  }
}

class ConnectivityState extends Equatable {
  final ConnectivityResult connectivityResult;
  final bool isConnected;

  const ConnectivityState.none()
      : connectivityResult = ConnectivityResult.none,
        isConnected = false;
  const ConnectivityState(this.connectivityResult, this.isConnected);

  @override
  List<Object?> get props => [connectivityResult, isConnected];

  @override
  String toString() =>
      '${connectivityResult.name}${isConnected ? '' : ' (no internet)'}';
}
