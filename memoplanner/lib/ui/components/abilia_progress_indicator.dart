import 'package:memoplanner/ui/all.dart';

class AbiliaProgressIndicator extends StatelessWidget {
  const AbiliaProgressIndicator({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
        valueColor: const AlwaysStoppedAnimation(AbiliaColors.red),
        strokeWidth: layout.progressIndicator.strokeWidth,
      );
}
