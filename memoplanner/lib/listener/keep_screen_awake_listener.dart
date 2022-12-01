import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';
import 'package:wakelock/wakelock.dart';

class KeepScreenAwakeListener
    extends BlocListener<WakeLockCubit, WakeLockState> {
  KeepScreenAwakeListener({Key? key})
      : super(
          key: key,
          listener: (context, state) async {
            if (state.screenTimeout > Duration.zero &&
                await SystemSettingsEditor.screenOffTimeout !=
                    state.screenTimeout) {
              await SystemSettingsEditor.setScreenOffTimeout(
                state.screenTimeout,
              );
            }
            if (state.onNow || Config.isMPLarge) {
              await Wakelock.enable();
            } else {
              await Wakelock.disable();
            }
          },
        );
}
