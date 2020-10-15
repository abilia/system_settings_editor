import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';

import 'package:permission_handler/permission_handler.dart';

class PermissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.permissions,
        closeIcon: AbiliaIcons.navigation_previous,
      ),
      body: BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 20.0, 16.0, 0),
          child: Column(
            children: state.status.entries
                .map((e) => PermissionSwitch(e))
                .expand((e) => [e, const SizedBox(height: 12.0)])
                .toList(),
          ),
        ),
      ),
    );
  }
}

class PermissionSwitch extends StatelessWidget {
  final Permission permission;
  final PermissionStatus status;

  PermissionSwitch(
    MapEntry<Permission, PermissionStatus> entry, {
    Key key,
  })  : permission = entry.key,
        status = entry.value,
        super(key: key);

  @override
  Widget build(BuildContext context) => SwitchField(
        text: Text(permission.translate(Translator.of(context).translate)),
        value: status.isGranted,
        onChanged: status.isGranted
            ? null
            : (_) => status.isUndetermined
                ? context
                    .bloc<PermissionBloc>()
                    .add(RequestPermission(permission))
                : openAppSettings(),
      );
}
