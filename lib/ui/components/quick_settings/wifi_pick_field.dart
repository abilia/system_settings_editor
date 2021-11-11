import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WifiPickWithLocationCheck extends StatelessWidget {
  const WifiPickWithLocationCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, permissionState) {
      final locationPermission = permissionState.status[Permission.location];
      if (locationPermission == PermissionStatus.denied) {
        context.read<PermissionBloc>().add(
              const RequestPermissions([Permission.location]),
            );
      }
      return WiFiPickField(
        locationPermission: locationPermission,
      );
    });
  }
}

class WiFiPickField extends StatefulWidget {
  const WiFiPickField({
    Key? key,
    this.networkInfo,
    required this.locationPermission,
  }) : super(key: key);
  final NetworkInfo? networkInfo;
  final PermissionStatus? locationPermission;

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
      leading: Icon(wifiName == null &&
              widget.locationPermission == PermissionStatus.granted
          ? AbiliaIcons.noWifi
          : AbiliaIcons.wifi),
      text: Text(t.wifi),
      secondaryText: widget.locationPermission == PermissionStatus.granted
          ? Text(
              wifiName ?? t.notConnected,
            )
          : null,
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
