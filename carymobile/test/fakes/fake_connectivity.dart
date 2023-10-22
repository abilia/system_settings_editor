import 'package:connectivity/connectivity_cubit.dart';
import 'package:mocktail/mocktail.dart';

class FakeConnectivity extends Fake implements Connectivity {
  @override
  Stream<ConnectivityResult> get onConnectivityChanged => const Stream.empty();
  @override
  Future<ConnectivityResult> checkConnectivity() async =>
      ConnectivityResult.wifi;
}
