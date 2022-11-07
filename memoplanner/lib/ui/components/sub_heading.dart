import 'package:memoplanner/ui/all.dart';

class SubHeading extends StatelessWidget {
  final String data;
  const SubHeading(this.data, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Tts.fromSemantics(
      SemanticsProperties(
        label: data,
        header: true,
      ),
      child: Padding(
        padding: layout.components.subHeadingPadding,
        child: Text(
          data,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              ?.copyWith(color: AbiliaColors.black75),
        ),
      ),
    );
  }
}
