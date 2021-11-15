import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WiFiPickField extends StatefulWidget {
  const WiFiPickField({
    Key? key,
    this.connectivity,
  }) : super(key: key);
  final Connectivity? connectivity;

  @override
  State<WiFiPickField> createState() => _WiFiPickFieldState();
}

class _WiFiPickFieldState extends State<WiFiPickField>
    with WidgetsBindingObserver {
  bool _connected = false;
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _connectivity = widget.connectivity ?? Connectivity();
    initWifiStatus();
  }

  void initWifiStatus() async {
    final connectivity = await _connectivity.checkConnectivity();
    setState(() {
      _connected = connectivity != ConnectivityResult.none;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      initWifiStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return PickField(
      leading: Icon(_connected ? AbiliaIcons.wifi : AbiliaIcons.noWifi),
      text: Text(t.wifi),
      secondaryText: Text(
        _connected ? t.connected : t.notConnected,
      ),
      secondaryStyle:
          (Theme.of(context).textTheme.bodyText2 ?? bodyText2).copyWith(
        height: 1.0,
        color: _connected ? AbiliaColors.green : AbiliaColors.red,
      ),
      onTap: () => AndroidIntents.openWifiSettings(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
