import 'dart:async';

import 'package:connectivity/myabilia_connection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/repository_base.dart';

export 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit({
    required this.connectivity,
    required this.baseUrlDb,
    required this.myAbiliaConnection,
    this.retryDelay = const Duration(seconds: 3),
    this.retryAttempts = 20,
  }) : super(const ConnectivityState.none()) {
    _onChangeSubscription =
        connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }
  final Duration retryDelay;
  final int retryAttempts;
  Timer? _retryTimer;

  final BaseUrlDb baseUrlDb;
  final Connectivity connectivity;
  final MyAbiliaConnection myAbiliaConnection;
  late final StreamSubscription _onChangeSubscription;
  late final log = Logger((ConnectivityCubit).toString());

  Future<void> checkConnectivity() async =>
      _onConnectivityChanged(await connectivity.checkConnectivity());

  Future _onConnectivityChanged(
    ConnectivityResult? result, {
    int retry = 0,
  }) async {
    final connectivityResult = result ?? state.connectivityResult;
    emit(ConnectivityState(connectivityResult, state.isConnected));
    final connected = await myAbiliaConnection.hasConnection();
    if (isClosed) return;
    emit(ConnectivityState(connectivityResult, connected));
    if (!connected &&
        retry < retryAttempts &&
        connectivityResult != ConnectivityResult.none) {
      log.info(
        'No connection to myAbilia, retrying in ${retryDelay.inSeconds} seconds. Attempt: $retry',
      );
      _retryTimer?.cancel();
      _retryTimer = Timer(
        retryDelay,
        () => _onConnectivityChanged(null, retry: retry + 1),
      );
    }
  }

  @override
  Future<void> close() async {
    _retryTimer?.cancel();
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
