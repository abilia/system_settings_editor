import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class FullscreenAlarmInfoDialog extends StatelessWidget {
  final bool showRedirect;

  const FullscreenAlarmInfoDialog({
    Key? key,
    this.showRedirect = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      bodyPadding:
          EdgeInsets.symmetric(horizontal: ViewDialog.horizontalPadding),
      expanded: true,
      backNavigationWidget: const CancelButton(),
      forwardNavigationWidget:
          showRedirect ? const RequestFullscreenNotificationButton() : null,
      body: Column(
        children: [
          const Spacer(flex: 64),
          const ActivityAlarmPreview(),
          const Spacer(flex: 24),
          Tts(
            child: Text(
              translate.fullScreenAlarm,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(height: 8.0.s),
          Tts(
            child: Text(
              translate.fullScreenAlarmInfo,
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    color: AbiliaColors.black75,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (showRedirect) ...[
            const Spacer(flex: 43),
            Tts(
              child: Text(
                translate.redirectToAndroidSettings,
                style: Theme.of(context).textTheme.caption?.copyWith(
                      color: AbiliaColors.black75,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 12.s),
          ] else
            const Spacer(flex: 71),
        ],
      ),
    );
  }
}

class ActivityAlarmPreview extends StatelessWidget {
  const ActivityAlarmPreview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime(2010, 10, 10, 18, 00);
    return AbsorbPointer(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(4.s)),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: Colors.black,
        child: SizedBox(
          height: 256.0.s,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: 450.0.s,
              height: 800.0.s,
              child: BlocProvider(
                create: (context) => ClockBloc.fixed(startTime),
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
  const RequestFullscreenNotificationButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => GreenButton(
        icon: AbiliaIcons.ok,
        text: Translator.of(context).translate.allow,
        onPressed: () async {
          context
              .read<PermissionBloc>()
              .add(const RequestPermissions([Permission.systemAlertWindow]));
          await Navigator.of(context).maybePop();
        },
      );
}
