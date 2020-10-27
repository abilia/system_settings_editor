import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PermissionInfoDialog extends StatelessWidget {
  final Permission permission;

  const PermissionInfoDialog({
    Key key,
    this.permission,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocListener<PermissionBloc, PermissionState>(
      listenWhen: (previous, current) => current.status[permission].isGranted,
      listener: (context, state) => Navigator.of(context).maybePop(),
      child: ViewDialog(
        verticalPadding: 0.0,
        leftPadding: 16.0,
        rightPadding: 16.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 72),
            Icon(
              permission.iconData,
              size: hugeIconSize,
            ),
            const Spacer(flex: 80),
            Tts(
              child: Text(
                permission.translate(translate),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const SizedBox(height: 8.0),
            PermissionInfoBodyText(
              allowAccessBodyText: body(translate),
            ),
            const Spacer(flex: 111),
            PermissionSwitch(
              permission: permission,
              status: PermissionStatus.permanentlyDenied,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String body(Translated translate) {
    switch (permission) {
      case Permission.camera:
        return translate.allowAccessCameraBody;
      case Permission.photos:
        return translate.allowAccessPhotosBody;
      default:
        return '';
    }
  }
}

class PermissionInfoBodyText extends StatelessWidget {
  const PermissionInfoBodyText({
    Key key,
    this.allowAccessBodyText,
  }) : super(key: key);

  final String allowAccessBodyText;
  @override
  Widget build(BuildContext context) {
    final b1 = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(color: AbiliaColors.black75);
    final translate = Translator.of(context).translate;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Tts.fromSemantics(
        SemanticsProperties(
            multiline: true,
            label: allowAccessBodyText +
                translate.allowAccessBody2 +
                translate.settingsLink),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: b1,
            children: [
              TextSpan(text: allowAccessBodyText),
              TextSpan(text: translate.allowAccessBody2),
              buildSettingsLinkTextSpan(context),
            ],
          ),
        ),
      ),
    );
  }
}

TextSpan buildSettingsLinkTextSpan(BuildContext context) => TextSpan(
      children: [
        TextSpan(
          text: Translator.of(context).translate.settingsLink,
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.of(context).pop();
              return Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PermissionsPage(),
                  settings: RouteSettings(name: 'PermissionPage'),
                ),
              );
            },
        ),
        TextSpan(text: '.'),
      ],
    );
