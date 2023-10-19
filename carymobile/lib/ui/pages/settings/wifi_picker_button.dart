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
      trailing: isConnected
          ? Text(Lt.of(context).connected, style: style)
          : Text(Lt.of(context).not_connected, style: style),
      onPressed: () async => const AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
      ).launch(),
    );
  }
}
