import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/ui/all.dart';

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
      bodyPadding: layout.templates.m4,
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
          SizedBox(height: layout.formPadding.verticalItemDistance),
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
            SizedBox(height: layout.formPadding.largeVerticalItemDistance),
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
        borderRadius: BorderRadius.all(Radius.circular(
          layout.activityPreview.radius,
        )),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: Colors.black,
        child: SizedBox(
          height: layout.activityPreview.height,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: layout.activityPreview.activityWidth,
              height: layout.activityPreview.activityHeight,
              child: BlocProvider(
                create: (context) => ClockBloc.fixed(startTime),
                child: AlarmPage(
                  previewImage: const Image(
                    image: AssetImage('assets/graphics/cake.gif'),
                    fit: BoxFit.cover,
                  ),
                  alarm: StartAlarm(
                    ActivityDay(
                      Activity(
                        title: Translator.of(context)
                            .translate
                            .previewActivityTitle,
                        startTime: startTime,
                        duration: 3.hours(),
                        calendarId: '',
                        timezone: '',
                      ),
                      startTime.onlyDays(),
                    ),
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
              .read<PermissionCubit>()
              .requestPermissions([Permission.systemAlertWindow]);
          await Navigator.of(context).maybePop();
        },
      );
}
