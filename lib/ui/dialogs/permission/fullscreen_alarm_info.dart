import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class FullscreenAlarmInfoDialog extends StatelessWidget {
  final bool showRedirect;

  const FullscreenAlarmInfoDialog({
    Key key,
    this.showRedirect = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      verticalPadding: 0.0,
      leftPadding: 32.0,
      rightPadding: 32.0,
      child: Column(
        children: [
          const Spacer(flex: 72),
          const ActivityAlarmPreview(),
          const SizedBox(height: 24),
          Tts(
            child: Text(
              translate.fullScreenAlarm,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const SizedBox(height: 8.0),
          Tts(
            child: Text(
              translate.fullScreenAlarmInfo,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: AbiliaColors.black75,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (showRedirect) ...[
            const Spacer(flex: 67),
            const RequestFullscreenNotificationButton(),
            const SizedBox(height: 8),
            Tts(
              child: Text(
                translate.redirectToAndroidSettings,
                style: Theme.of(context).textTheme.caption.copyWith(
                      color: AbiliaColors.black75,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ] else
            const Spacer(flex: 171),
        ],
      ),
    );
  }
}

class ActivityAlarmPreview extends StatelessWidget {
  const ActivityAlarmPreview({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime(2010, 10, 10, 18, 00);
    return AbsorbPointer(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: AbiliaColors.transparentBlack50,
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            )
          ],
        ),
        child: SizedBox(
          height: 256,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: 450.0,
              height: 800.0,
              child: BlocProvider(
                create: (context) => ClockBloc(
                    StreamController<DateTime>().stream,
                    initialTime: startTime),
                child: AlarmPage(
                  previewImage: const Image(
                    image: AssetImage('assets/graphics/cake.gif'),
                    fit: BoxFit.cover,
                  ),
                  alarm: StartAlarm(
                    Activity.createNew(
                      title:
                          Translator.of(context).translate.previewActivityTitle,
                      startTime: startTime,
                      duration: 3.hours(),
                    ),
                    startTime.onlyDays(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RequestFullscreenNotificationButton extends StatelessWidget {
  const RequestFullscreenNotificationButton();
  @override
  Widget build(BuildContext context) {
    final text = Translator.of(context).translate.allow;
    return Theme(
      data: greenButtonTheme,
      child: Tts(
        data: text,
        child: FlatButton(
          color: greenButtonTheme.buttonColor,
          child: Text(
            text,
            style: greenButtonTheme.textTheme.button,
          ),
          onPressed: () async {
            await openSystemAlertSetting();
            await Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}
