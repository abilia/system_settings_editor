import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class WiFiPickField extends StatelessWidget {
  const WiFiPickField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final connectedState = context.watch<ConnectivityCubit>().state;
    final wifi = connectedState.connectivityResult == ConnectivityResult.wifi;
    final internet = connectedState.isConnected;
    final style = Theme.of(context).textTheme.bodyMedium ?? bodyMedium;
    return PickField(
      leading: Icon(wifi ? AbiliaIcons.wifi : AbiliaIcons.noWifi),
      text: Text(translate.wifi),
      trailingText: internet
          ? Text(
              translate.connected,
              style: style.copyWith(color: AbiliaColors.green),
            )
          : Text(
              wifi ? translate.connectedNoInternet : translate.notConnected,
              style: style.copyWith(color: AbiliaColors.red),
            ),
      onTap: AndroidIntents.openWifiSettings,
    );
  }
}
