import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class KeepScreenAwakeListener
    extends BlocListener<WakeLockCubit, WakeLockState> {
  static const intMax = 2147483647;
  KeepScreenAwakeListener({Key? key})
      : super(
          key: key,
          listener: (context, state) async {
            if (!await SystemSettingsEditor.canWriteSettings) return;
            if (state.onNow) {
              await SystemSettingsEditor.setScreenOffTimeout(
                const Duration(milliseconds: intMax),
              );
            } else if (state.systemScreenTimeout > Duration.zero &&
                await SystemSettingsEditor.screenOffTimeout !=
                    state.systemScreenTimeout) {
              await SystemSettingsEditor.setScreenOffTimeout(
                state.systemScreenTimeout,
              );
            }
          },
        );
}
