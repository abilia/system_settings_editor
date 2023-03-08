import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/main.dart';
import 'package:memoplanner/ui/all.dart';

extension IncreaseSizeOnMp on WidgetTester {
  Future<void> pumpApp({bool use24 = false, PushCubit? pushCubit}) async {
    _increaseSizeOnMp(use24: use24);
    await pumpWidget(App(pushCubit: pushCubit));
    await pumpAndSettle();
  }

  Future<void> pumpWidgetWithMPSize(Widget widget, {bool use24 = false}) async {
    _increaseSizeOnMp(use24: use24);
    await pumpWidget(widget);
  }

  void _increaseSizeOnMp({bool use24 = false}) {
    if (Config.isMP) {
      setScreenSize(const Size(800, 1280));
    }
    if (use24) {
      binding.platformDispatcher.alwaysUse24HourFormatTestValue = use24;
      addTearDown(binding.platformDispatcher.clearAlwaysUse24HourTestValue);
    }
  }

  void setScreenSize(Size size) {
    binding.window.physicalSizeTestValue = size;
    binding.window.devicePixelRatioTestValue = 1;
    addTearDown(binding.window.clearPhysicalSizeTestValue);
    addTearDown(binding.window.clearDevicePixelRatioTestValue);
  }
}
