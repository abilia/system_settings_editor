import 'dart:async';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/push.dart';
import 'package:mocktail/mocktail.dart';
import 'package:utils/utils.dart';

class FakeSyncBloc extends Fake implements SyncBloc {
  @override
  Stream<Synced> get stream => const Stream.empty();

  @override
  void add(Object event) {}

  @override
  Future<bool> hasDirty() => Future.value(false);

  @override
  Future<void> close() async {}
}

class MockLastSyncDb extends Mock implements LastSyncDb {}

class FakeLastSyncDb extends Fake implements LastSyncDb {
  int? fakeLastSync;

  @override
  Future<void> setSyncTime(DateTime syncTime) async {
    fakeLastSync = syncTime.millisecondsSinceEpoch;
  }

  @override
  DateTime? getLastSyncTime() => fakeLastSync.fromMillisecondsSinceEpoch();
}

class FakeFirebasePushService extends Fake implements FirebasePushService {
  @override
  Future<String?> initPushToken() => Future.value('fakeToken');
}
