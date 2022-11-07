import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class WiFiPickField extends StatelessWidget {
  const WiFiPickField({
    Key? key,
    this.connectivity,
  }) : super(key: key);
  final Connectivity? connectivity;

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final c = connectivity ?? Connectivity();
    return StreamBuilder<ConnectivityResult>(
      stream: c.onConnectivityChanged,
      builder: (context, _) {
        return FutureBuilder(
          future: c.checkConnectivity(),
          builder: (context, snapshot) {
            final bool connected = snapshot.data != ConnectivityResult.none;
            return PickField(
              leading: Icon(connected ? AbiliaIcons.wifi : AbiliaIcons.noWifi),
              text: Text(t.wifi),
              trailingText: Text(
                connected ? t.connected : t.notConnected,
                style: (Theme.of(context).textTheme.bodyText2 ?? bodyText2)
                    .copyWith(
                  color: connected ? AbiliaColors.green : AbiliaColors.red,
                ),
              ),
              onTap: AndroidIntents.openWifiSettings,
            );
          },
        );
      },
    );
  }
}
