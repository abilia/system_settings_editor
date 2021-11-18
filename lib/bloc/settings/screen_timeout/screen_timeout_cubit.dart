import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/generic/generic_bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';
import 'package:wakelock/wakelock.dart';

class ScreenTimeoutCubit extends Cubit<Duration> {
  ScreenTimeoutCubit({required Duration initialState}) : super(initialState) {
    _init();
  }

  _init() async {
    emit(await SystemSettingsEditor.screenOffTimeout ?? const Duration());
  }

  @override
  void emit(Duration state) {
    super.emit(state);
  }

  void updateTimeout(Duration? timeout) {
    if (timeout != null) {
      SystemSettingsEditor.setScreenOffTimeout(timeout);
      if (timeout.inMinutes > 0) {
        Wakelock.disable();
      } else {
        Wakelock.enable();
      }
      emit(timeout);
    }
  }
}
