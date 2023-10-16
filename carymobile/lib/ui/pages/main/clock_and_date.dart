part of 'main_page.dart';

class ClockAndDate extends StatelessWidget {
  final bool expanded;
  const ClockAndDate({required this.expanded, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: expanded ? theme : collapsed(theme),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: BlocBuilder<ClockCubit, DateTime>(
          builder: (context, time) => Tts.data(
            data: DateFormat().add_Hm().add_EEEE().add_yMMMMd().format(time),
            child: Flex(
              direction: expanded ? Axis.horizontal : Axis.vertical,
              verticalDirection: VerticalDirection.up,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.start,
              children: [
                TimeDateText(time: time),
                if (expanded)
                  SizedBox.fromSize(
                    size: CaryTheme.of(context).clockDatePadding,
                  ),
                SizedBox.square(
                  dimension: CaryTheme.of(context).clockSize,
                  child: AnalogClock(time),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimeDateText extends StatelessWidget {
  final DateTime time;
  const TimeDateText({required this.time, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final padding = SizedBox(height: CaryTheme.of(context).datePadding);
    return DefaultTextStyle(
      style: textTheme.titleMedium ?? titleMedium,
      maxLines: 1,
      child: Flexible(
        child: Column(
          children: [
            AutoSizeText(
              DateFormat.Hm().format(time),
              style: textTheme.titleLarge ?? titleLarge,
            ),
            padding,
            AutoSizeText(Lt.of(context).mid_morning),
            padding,
            AutoSizeText(DateFormat.EEEE().format(time)),
            padding,
            AutoSizeText(DateFormat.yMMMMd().format(time)),
          ],
        ),
      ),
    );
  }
}
