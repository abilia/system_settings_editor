import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class SelectRecurrentTypePage extends StatefulWidget {
  final bool allDaysVisible, thisDayAndForwardVisible;
  final String heading;
  final IconData headingIcon;

  const SelectRecurrentTypePage({
    Key? key,
    this.allDaysVisible = false,
    this.thisDayAndForwardVisible = true,
    required this.heading,
    required this.headingIcon,
  }) : super(key: key);
  @override
  _SelectRecurrentTypePageState createState() =>
      _SelectRecurrentTypePageState();
}

class _SelectRecurrentTypePageState extends State<SelectRecurrentTypePage> {
  ApplyTo applyTo = ApplyTo.onlyThisDay;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: widget.heading,
        iconData: widget.headingIcon,
      ),
      body: Padding(
        padding: layout.templates.m1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RadioField(
              key: TestKey.onlyThisDay,
              leading: const Icon(AbiliaIcons.day),
              text: Text(translate.onlyThisDay),
              value: ApplyTo.onlyThisDay,
              groupValue: applyTo,
              onChanged: _radioChanged,
            ),
            if (widget.allDaysVisible) ...[
              SizedBox(height: layout.formPadding.verticalItemDistance),
              RadioField(
                key: TestKey.allDays,
                leading: const Icon(AbiliaIcons.month),
                text: Text(translate.allDays),
                value: ApplyTo.allDays,
                groupValue: applyTo,
                onChanged: _radioChanged,
              ),
            ],
            if (widget.thisDayAndForwardVisible) ...[
              SizedBox(height: layout.formPadding.verticalItemDistance),
              RadioField(
                key: TestKey.thisDayAndForward,
                leading: const Icon(AbiliaIcons.week),
                text: Text(translate.thisDayAndForward),
                value: ApplyTo.thisDayAndForward,
                groupValue: applyTo,
                onChanged: _radioChanged,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: OkButton(
            onPressed: () => Navigator.of(context).pop(applyTo),
          )),
    );
  }

  void _radioChanged(v) => setState(() => {applyTo = v});
}
