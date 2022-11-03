import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class DigitalClock extends StatelessWidget {
  final TextStyle? style;
  const DigitalClock({Key? key, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, time) => Tts(
        child: Text(
          hourAndMinuteFormat(context)(time),
          textAlign: TextAlign.center,
          style: style ?? Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }
}
