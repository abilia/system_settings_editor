import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WiFiPickField extends StatelessWidget {
  const WiFiPickField({
    Key? key,
    this.connectivity,
  }) : super(key: key);
  final Connectivity? connectivity;

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return StreamBuilder<ConnectivityResult>(
      stream: (connectivity ?? Connectivity()).onConnectivityChanged,
      builder: (context, snapshot) {
        final bool _connected = snapshot.data != ConnectivityResult.none;
        return PickField(
          leading: Icon(_connected ? AbiliaIcons.wifi : AbiliaIcons.noWifi),
          text: Text(t.wifi),
          secondaryText: Text(
            _connected ? t.connected : t.notConnected,
            style:
                (Theme.of(context).textTheme.bodyText2 ?? bodyText2).copyWith(
              height: 1.0,
              color: _connected ? AbiliaColors.green : AbiliaColors.red,
            ),
          ),
          onTap: AndroidIntents.openWifiSettings,
        );
      },
    );
  }
}
