import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ScreenTimeoutPickField extends StatelessWidget {
  const ScreenTimeoutPickField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final translate = Lt.of(context);
    return BlocBuilder<WakeLockCubit, WakeLockState>(
      builder: (context, wakeLockState) => PickField(
        text: Text(
          wakeLockState.alwaysOn
              ? translate.alwaysOn
              : wakeLockState.screenTimeout.toDurationString(translate),
        ),
        onTap: () async {
          final wakeLockCubit = context.read<WakeLockCubit>();
          final timeout = await Navigator.of(context).push<Duration>(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: authProviders,
                child: ScreenTimeOutSelectorPage(
                  timeout: wakeLockState.screenTimeout,
                ),
              ),
              settings: (ScreenTimeOutSelectorPage).routeSetting(),
            ),
          );
          wakeLockCubit.setScreenTimeout(timeout);
        },
      ),
    );
  }
}

class ScreenTimeOutSelectorPage extends StatefulWidget {
  final Duration timeout;

  const ScreenTimeOutSelectorPage({
    required this.timeout,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenTimeOutSelectorPageState();
  }
}

class ScreenTimeOutSelectorPageState extends State<ScreenTimeOutSelectorPage> {
  late Duration _timeout;

  @override
  void initState() {
    super.initState();
    _timeout = widget.timeout;
  }

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
        title: translate.screenTimeout,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: (Theme.of(context).textTheme.bodyMedium ?? bodyMedium)
                  .copyWith(color: AbiliaColors.black75),
              child: ListView(
                padding: layout.templates.m1,
                children: [
                  ...{
                    const Duration(minutes: 1),
                    const Duration(minutes: 30),
                    maxScreenTimeoutDuration,
                    _timeout,
                  }.map(
                    (d) => Padding(
                      padding: EdgeInsets.only(
                        bottom: layout.formPadding.verticalItemDistance,
                      ),
                      child: RadioField<Duration>(
                        text: Text(
                          d.inDays > 1
                              ? translate.alwaysOn
                              : d.toDurationString(translate),
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
    final keepScreenOnWhileCharging = context
        .select((WakeLockCubit cubit) => cubit.state.keepScreenOnWhileCharging);
    return SwitchField(
      value: keepScreenOnWhileCharging,
      onChanged: (switchOn) async {
        await context
            .read<WakeLockCubit>()
            .setKeepScreenOnWhileCharging(switchOn);
      },
      child: Text(Lt.of(context).keepScreenAwakeWhileCharging),
    );
  }
}
