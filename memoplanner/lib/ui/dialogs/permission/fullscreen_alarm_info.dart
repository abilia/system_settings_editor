import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class FullscreenAlarmInfoDialog extends StatelessWidget {
  final bool showRedirect;

  const FullscreenAlarmInfoDialog({
    this.showRedirect = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return BlocListener<PermissionCubit, PermissionState>(
      listenWhen: (previous, current) =>
          previous.status[Permission.systemAlertWindow]?.isGranted == false &&
          current.status[Permission.systemAlertWindow]?.isGranted == true,
      listener: (context, state) => Navigator.of(context).pop(),
      child: ViewDialog(
        bodyPadding: layout.templates.m4,
        expanded: true,
        backNavigationWidget: CancelButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        forwardNavigationWidget: showRedirect
            ? GreenButton(
                icon: AbiliaIcons.ok,
                text: Lt.of(context).allow,
                onPressed: () async => context
                    .read<PermissionCubit>()
                    .request([Permission.systemAlertWindow]))
            : null,
        body: Column(
          children: [
            const Spacer(flex: 64),
            const ActivityAlarmPreview(),
            const Spacer(flex: 24),
            Tts(
              child: Text(
                translate.fullScreenAlarm,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(height: layout.formPadding.verticalItemDistance),
            Tts(
              child: Text(
                translate.fullScreenAlarmInfo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      ),
    );
  }
}

class ActivityAlarmPreview extends StatelessWidget {
  const ActivityAlarmPreview({
    super.key,
  });

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
                create: (context) => ClockCubit.fixed(startTime),
                child: AlarmPage(
                  previewImage: const Image(
                    image: AssetImage('assets/graphics/cake.gif'),
                    fit: BoxFit.cover,
                  ),
                  alarm: StartAlarm(
                    ActivityDay(
                      Activity(
                        title: Lt.of(context).previewActivityTitle,
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
