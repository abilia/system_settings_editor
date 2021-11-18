import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/generic/generic_bloc.dart';
import 'package:seagull/bloc/generic/memoplannersetting/memoplanner_setting_bloc.dart';
import 'package:seagull/bloc/providers.dart';
import 'package:seagull/bloc/settings/screen_timeout/screen_timeout_cubit.dart';
import 'package:seagull/bloc/settings/screen_timeout/wake_lock_cubit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/models/generic/generic.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/duration.dart';

class ScreenTimeout extends StatelessWidget {
  const ScreenTimeout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenTimeoutPickField();
  }
}

class ScreenTimeoutPickField extends StatelessWidget {
  const ScreenTimeoutPickField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<WakeLockCubit, ScreenAwakeState>(
      builder: (context, wakeLockState) => PickField(
        text: Text(wakeLockState.screenTimeout.inMinutes != 0
            ? wakeLockState.screenTimeout.toDurationString(t, shortMin: false)
            : t.alwaysOn),
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
          BlocProvider.of<WakeLockCubit>(context).setScreenTimeout(timeout);
        },
      ),
    );
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

class ScreenTimeOutSelectorState extends State<ScreenTimeOutSelector> {
  Duration? _timeout;

  @override
  void initState() {
    super.initState();
    _timeout = widget.timeout;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
        title: t.selectType,
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
                                    : d.toDurationString(t, shortMin: false),
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
    return BlocBuilder<WakeLockCubit, ScreenAwakeState>(
      builder: (context, wakeLockState) => SwitchField(
        value: wakeLockState.screenOnWhileCharging,
        onChanged: (switchOn) {
          BlocProvider.of<WakeLockCubit>(context)
              .setKeepScreenAwakeWhilePluggedIn(switchOn);
        },
        child: Text(Translator.of(context).translate.clickSound),
      ),
    );
  }
}
