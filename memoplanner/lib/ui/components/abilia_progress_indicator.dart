import 'package:memoplanner/ui/all.dart';

class AbiliaProgressIndicator extends StatelessWidget {
  const AbiliaProgressIndicator({this.strokeWidth, Key? key}) : super(key: key);
  final double? strokeWidth;
  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
        valueColor: const AlwaysStoppedAnimation(AbiliaColors.red),
        strokeWidth: strokeWidth ?? layout.progressIndicator.strokeWidth,
      );
}
