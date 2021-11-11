import 'package:network_info_plus/network_info_plus.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WiFiPickField extends StatefulWidget {
  const WiFiPickField({Key? key, this.networkInfo}) : super(key: key);
  final NetworkInfo? networkInfo;

  @override
  State<WiFiPickField> createState() => _WiFiPickFieldState();
}

class _WiFiPickFieldState extends State<WiFiPickField>
    with WidgetsBindingObserver {
  String? wifiName;
  late final NetworkInfo info;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    info = widget.networkInfo ?? NetworkInfo();
    initWifiName();
  }

  void initWifiName() async {
    final name = await info.getWifiName();
    setState(() {
      wifiName = name;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      final name = await info.getWifiName();
      setState(() {
        wifiName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return PickField(
      leading: Icon(wifiName == null ? AbiliaIcons.noWifi : AbiliaIcons.wifi),
      text: Text(t.wifi),
      secondaryText: Text(
        wifiName ?? t.notConnected,
      ),
      secondaryStyle: wifiName == null
          ? (Theme.of(context).textTheme.bodyText2 ?? bodyText2).copyWith(
              height: 1.0,
              color: AbiliaColors.red,
            )
          : null,
      onTap: () => AndroidIntents.openWifiSettings(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
