part of 'settings_page.dart';

class WifiPickerButton extends StatelessWidget {
  const WifiPickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected =
        context.select((ConnectivityCubit cubit) => cubit.state.isConnected);
    final style = actionButtonTextStyle.copyWith(color: abiliaWhite140);
    return PickerButtonWhite(
      leading: Icon(isConnected ? AbiliaIcons.wifi : AbiliaIcons.noWifi),
      leadingText: Lt.of(context).internet,
      trailing: Text(
        isConnected ? Lt.of(context).connected : Lt.of(context).not_connected,
        style: style,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
      ),
      onPressed: () async => const AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
      ).launch(),
    );
  }
}
