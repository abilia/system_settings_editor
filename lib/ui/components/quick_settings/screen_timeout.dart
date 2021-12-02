import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/providers.dart';
import 'package:seagull/bloc/settings/screen_timeout/wake_lock_cubit.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/duration.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class ScreenTimeoutPickField extends StatefulWidget {
  const ScreenTimeoutPickField({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenTimeoutPickState();
  }
}

class ScreenTimeoutPickState extends State<ScreenTimeoutPickField>
    with WidgetsBindingObserver {
  final _log = Logger((ScreenTimeOutSelectorState).toString());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _initTimeout();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initTimeout();
    }
  }

  void _initTimeout() async {
    try {
      final timeout = await SystemSettingsEditor.screenOffTimeout;
      if (timeout != null) {
        BlocProvider.of<WakeLockCubit>(context).setScreenTimeout(timeout);
      }
    } on PlatformException catch (e) {
      _log.warning('Could not get timeout', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<WakeLockCubit, KeepScreenAwakeState>(
      builder: (context, wakeLockState) => PickField(
        text: Text(wakeLockState.screenTimeout == WakeLockCubit.timeoutDisabled
            ? t.alwaysOn
            : wakeLockState.screenTimeout.toDurationString(t)),
        onTap: () async {
          final timeout = await Navigator.of(context).push<Duration>(
            MaterialPageRoute(
              builder: (_) => CopiedAuthProviders(
                blocContext: context,
                child:
                    ScreenTimeOutSelector(timeout: wakeLockState.screenTimeout),
              ),
            ),
          );
          if (timeout != null) {
            BlocProvider.of<WakeLockCubit>(context).setScreenTimeout(timeout);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}

class ScreenTimeOutSelector extends StatefulWidget {
  final Duration? timeout;

  const ScreenTimeOutSelector({Key? key, this.timeout}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenTimeOutSelectorState();
  }
}

class ScreenTimeOutSelectorState extends State<ScreenTimeOutSelector>
    with WidgetsBindingObserver {
  Duration? _timeout;
  final _log = Logger((ScreenTimeOutSelectorState).toString());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _timeout = widget.timeout;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initTimeout();
    }
  }

  void _initTimeout() async {
    try {
      final timeout = await SystemSettingsEditor.screenOffTimeout;
      setState(() {
        _timeout = timeout ?? const Duration(minutes: -1);
      });
    } on PlatformException catch (e) {
      _log.warning('Could not get timeout', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
        title: t.screenTimeout,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: (Theme.of(context).textTheme.bodyText2 ?? bodyText2)
                  .copyWith(color: AbiliaColors.black75),
              child: ListView(
                padding: EdgeInsets.only(top: 24.0.s),
                children: [
                  ...[1, 30, 0].map((d) => d.minutes()).map(
                        (d) => Padding(
                          padding: EdgeInsets.only(
                              left: 12.s, right: 16.s, bottom: 8.s),
                          child: RadioField<Duration>(
                              text: Text(
                                d.inMilliseconds == 0
                                    ? t.alwaysOn
                                    : d.toDurationString(t),
                              ),
                              onChanged: (v) => setState(() => _timeout = v),
                              groupValue: _timeout,
                              value: d),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        forwardNavigationWidget: OkButton(
          onPressed: () => Navigator.of(context).pop(_timeout),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}

class KeepOnWhileChargingSwitch extends StatefulWidget {
  const KeepOnWhileChargingSwitch({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _KeepOnWhileChargingSwitchState();
  }
}

class _KeepOnWhileChargingSwitchState extends State<KeepOnWhileChargingSwitch> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WakeLockCubit, KeepScreenAwakeState>(
      builder: (context, wakeLockState) => SwitchField(
        value: wakeLockState.screenOnWhileCharging,
        onChanged: (switchOn) {
          BlocProvider.of<WakeLockCubit>(context)
              .setKeepScreenAwakeWhilePluggedIn(switchOn);
        },
        child:
            Text(Translator.of(context).translate.keepScreenAwakeWhileCharging),
      ),
    );
  }
}
