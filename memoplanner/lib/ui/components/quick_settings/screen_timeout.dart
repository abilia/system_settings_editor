import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ScreenTimeoutPickField extends StatelessWidget {
  const ScreenTimeoutPickField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final t = Translator.of(context).translate;
    return BlocBuilder<WakeLockCubit, WakeLockState>(
      builder: (context, wakeLockState) => PickField(
        text: Text(
          wakeLockState.alwaysOn
              ? t.alwaysOn
              : wakeLockState.screenTimeout.toDurationString(t),
        ),
        onTap: () async {
          final genericCubit = context.read<GenericCubit>();
          final wakeLockCubit = context.read<WakeLockCubit>();
          final timeout = await Navigator.of(context).push<Duration>(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: authProviders,
                child: ScreenTimeOutSelector(
                  timeout:
                      wakeLockState.keepScreenAwakeSettings.keepScreenOnAlways
                          ? Duration.zero
                          : wakeLockState.screenTimeout,
                ),
              ),
            ),
          );
          if (timeout != null) {
            genericCubit.genericUpdated(
              [
                MemoplannerSettingData.fromData(
                  data: timeout == Duration.zero,
                  identifier: KeepScreenAwakeSettings.keepScreenOnAlwaysKey,
                ),
              ],
            );
            wakeLockCubit.setScreenTimeout(timeout);
          }
        },
      ),
    );
  }
}

class ScreenTimeOutSelector extends StatefulWidget {
  final Duration timeout;

  const ScreenTimeOutSelector({
    required this.timeout,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenTimeOutSelectorState();
  }
}

class ScreenTimeOutSelectorState extends State<ScreenTimeOutSelector> {
  late Duration _timeout;

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
                padding: layout.templates.m1,
                children: [
                  ...([1, 30, 0].map((d) => d.minutes()).toSet()..add(_timeout))
                      .map(
                    (d) => Padding(
                      padding: EdgeInsets.only(
                        bottom: layout.formPadding.verticalItemDistance,
                      ),
                      child: RadioField<Duration>(
                        text: Text(
                          d.inMilliseconds == 0
                              ? t.alwaysOn
                              : d.toDurationString(t),
                        ),
                        onChanged: (v) {
                          if (v != null) setState(() => _timeout = v);
                        },
                        groupValue: _timeout,
                        value: d,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () => Navigator.of(context).pop(_timeout),
        ),
      ),
    );
  }
}

class KeepOnWhileChargingSwitch extends StatelessWidget {
  const KeepOnWhileChargingSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keepScreenOnWhileCharging = context.select(
        (MemoplannerSettingsBloc bloc) =>
            bloc.state.keepScreenAwake.keepScreenOnWhileCharging);
    return SwitchField(
      value: keepScreenOnWhileCharging,
      onChanged: (switchOn) {
        context.read<GenericCubit>().genericUpdated(
          [
            MemoplannerSettingData.fromData(
              data: switchOn,
              identifier: KeepScreenAwakeSettings.keepScreenOnWhileChargingKey,
            ),
          ],
        );
      },
      child:
          Text(Translator.of(context).translate.keepScreenAwakeWhileCharging),
    );
  }
}
